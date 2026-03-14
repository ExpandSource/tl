#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MODULE_DIR       "/usr/share/tl/modules"
#define MODULE_DIR_LOCAL "./modules"
#define CONF_FILE        "tl.conf"
#define STATE_FILE       ".tl_state"
#define MAX_PATH         512
#define BUF_SIZE         4096
#define MAX_CAT          16
#define MAX_MOD          32

/* ------------------------------------------------------------------ */
/* 출력 파서                                                            */
/* ------------------------------------------------------------------ */

/*
 * 인라인 태그 파싱 — 모두 줄 중간에 혼용 가능
 *   `...`  Green+굵게         (명령어)
 *   #...#  Yellow+굵게        (섹션 헤더 / 위치 표시)
 *   ~...~  Magenta+Italic     (추천 심화 모듈)
 *   *...*  Cyan BG+밑줄       (네비게이션: 이전/다음 이동)
 *   그 외  White
 */
static void print_line(const char *line) {
    fputs("\033[37m", stdout);
    const char *p = line;
    while (*p && *p != '\n') {
        if (*p == '`') {
            fputs("\033[1;32m", stdout); ++p;
            while (*p && *p != '`' && *p != '\n') putchar(*p++);
            if (*p == '`') ++p;
            fputs("\033[0;37m", stdout);
        } else if (*p == '#') {
            fputs("\033[1;33m", stdout); ++p;
            while (*p && *p != '#' && *p != '\n') putchar(*p++);
            if (*p == '#') ++p;
            fputs("\033[0;37m", stdout);
        } else if (*p == '~') {
            fputs("\033[3;35m", stdout); ++p;
            while (*p && *p != '~' && *p != '\n') putchar(*p++);
            if (*p == '~') ++p;
            fputs("\033[0;37m", stdout);
        } else if (*p == '*') {
            fputs("\033[4;46m", stdout); ++p;
            while (*p && *p != '*' && *p != '\n') putchar(*p++);
            if (*p == '*') ++p;
            fputs("\033[0;49;24;37m", stdout);
        } else {
            putchar(*p++);
        }
    }
    fputs("\033[0m\n", stdout);
}

static int print_file(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return -1;
    char buf[BUF_SIZE];
    while (fgets(buf, sizeof(buf), f))
        print_line(buf);
    fclose(f);
    return 0;
}

/* ------------------------------------------------------------------ */
/* conf 로드                                                            */
/* ------------------------------------------------------------------ */

typedef struct {
    char name[64];
    char desc[128];
} Mod;

typedef struct {
    int  id;
    char title[64];
    Mod  mods[MAX_MOD];
    int  cnt;
} Cat;

static Cat g_cats[MAX_CAT];
static int g_ncat = 0;

static void conf_load(const char *base) {
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "%s/%s", base, CONF_FILE);
    FILE *f = fopen(path, "r");
    if (!f) return;

    char buf[BUF_SIZE];
    Cat *cur = NULL;

    while (fgets(buf, sizeof(buf), f)) {
        /* 주석·빈 줄 */
        if (buf[0] == '#' || buf[0] == '\n' || buf[0] == '\r') continue;

        /* [N] — 카테고리 시작 */
        if (buf[0] == '[') {
            int id = atoi(buf + 1);
            if (id < 1 || g_ncat >= MAX_CAT) continue;
            cur = &g_cats[g_ncat++];
            cur->id  = id;
            cur->cnt = 0;
            cur->title[0] = '\0';
            continue;
        }
        if (!cur) continue;

        /* title= */
        if (strncmp(buf, "title=", 6) == 0) {
            char *v = buf + 6;
            int i = 0;
            while (v[i] && v[i] != '\n' && i < 63) i++;
            strncpy(cur->title, v, i);
            cur->title[i] = '\0';
            continue;
        }

        /* N=name desc */
        if (buf[0] >= '1' && buf[0] <= '9' && cur->cnt < MAX_MOD) {
            char *eq = strchr(buf, '=');
            if (!eq) continue;
            char *p = eq + 1;
            Mod *m = &cur->mods[cur->cnt++];
            /* name */
            int ni = 0;
            while (*p && *p != ' ' && *p != '\t' && *p != '\n' && ni < 63)
                m->name[ni++] = *p++;
            m->name[ni] = '\0';
            /* desc (trim leading space) */
            while (*p == ' ' || *p == '\t') p++;
            int di = 0;
            while (*p && *p != '\n' && di < 127)
                m->desc[di++] = *p++;
            m->desc[di] = '\0';
        }
    }
    fclose(f);
}

/* 카테고리 id → 인덱스 */
static Cat *find_cat(int id) {
    for (int i = 0; i < g_ncat; i++)
        if (g_cats[i].id == id) return &g_cats[i];
    return NULL;
}

/* 이름으로 (cat, mod) 찾기 → 0-based mod idx 반환, 없으면 -1 */
static int find_by_name(const char *name, int *cat_id) {
    for (int i = 0; i < g_ncat; i++)
        for (int j = 0; j < g_cats[i].cnt; j++)
            if (strcmp(g_cats[i].mods[j].name, name) == 0) {
                *cat_id = g_cats[i].id;
                return j;           /* 0-based */
            }
    return -1;
}

/* 전역 순서 (cat, 1-based mod) → 전역 인덱스 */
static int global_idx(int cat_id, int mod1) {
    int g = 0;
    for (int i = 0; i < g_ncat; i++) {
        if (g_cats[i].id == cat_id)
            return g + mod1 - 1;
        g += g_cats[i].cnt;
    }
    return -1;
}

/* 전역 인덱스 → (cat_id, 1-based mod) */
static int global_to_pos(int gi, int *cat_id, int *mod1) {
    int g = 0;
    for (int i = 0; i < g_ncat; i++) {
        if (gi < g + g_cats[i].cnt) {
            *cat_id = g_cats[i].id;
            *mod1   = gi - g + 1;
            return 0;
        }
        g += g_cats[i].cnt;
    }
    return -1;
}

static int total_mods(void) {
    int t = 0;
    for (int i = 0; i < g_ncat; i++) t += g_cats[i].cnt;
    return t;
}

/* ------------------------------------------------------------------ */
/* state                                                                */
/* ------------------------------------------------------------------ */

typedef struct { int cat; int mod; } State;  /* mod: 1-based */

static char *state_path(void) {
    static char buf[MAX_PATH];
    const char *home = getenv("HOME");
    if (!home) home = ".";
    snprintf(buf, sizeof(buf), "%s/%s", home, STATE_FILE);
    return buf;
}

static State state_load(void) {
    State s = {0, 0};
    FILE *f = fopen(state_path(), "r");
    if (!f) return s;
    if (fscanf(f, "%d %d", &s.cat, &s.mod) != 2) { s.cat = 0; s.mod = 0; }
    fclose(f);
    return s;
}

static void state_save(int cat, int mod) {
    FILE *f = fopen(state_path(), "w");
    if (!f) return;
    fprintf(f, "%d %d\n", cat, mod);
    fclose(f);
}

/* ------------------------------------------------------------------ */
/* 모듈 파일 경로 및 출력                                               */
/* ------------------------------------------------------------------ */

static int print_mod(const char *base, int cat_id, int mod1) {
    Cat *c = find_cat(cat_id);
    if (!c || mod1 < 1 || mod1 > c->cnt) return -1;
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "%s/%d/%s.txt", base, cat_id, c->mods[mod1-1].name);
    return print_file(path);
}

/* ------------------------------------------------------------------ */
/* 커맨드 구현                                                          */
/* ------------------------------------------------------------------ */

static void cmd_index(const char *base) {
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "%s/../index.txt", base);
    printf("\033[1;33mtl\033[0m \033[37m— tutorial for linux\033[0m\n\n");
    FILE *f = fopen(path, "r");
    if (f) {
        char buf[BUF_SIZE];
        while (fgets(buf, sizeof(buf), f)) print_line(buf);
        fclose(f);
    }
    printf("\n\033[1;33mdo it!\033[0m\033[37m ▶\033[0m  "
           "\033[1;32mtl 1\033[0m"
           "\033[37m  또는  \033[0m"
           "\033[1;32mtl shell\033[0m\n");
    printf("\033[4;36m모듈 목록: tl list  |  마지막: tl z  |  다음: tl n\033[0m\n");
}

static void cmd_category(int cat_id) {
    Cat *c = find_cat(cat_id);
    if (!c) { fprintf(stderr, "tl: category %d not found\n", cat_id); return; }
    printf("\033[1;33m%d. %s\033[0m\n\n", c->id, c->title);
    for (int i = 0; i < c->cnt; i++)
        printf("  \033[1;32m%d-%d  tl %-14s\033[0;37m %s\033[0m\n",
               c->id, i+1, c->mods[i].name, c->mods[i].desc);
}

static int cmd_cat_mod(const char *base, int cat_id, int mod1) {
    if (print_mod(base, cat_id, mod1) != 0) {
        fprintf(stderr, "tl: %d-%d not found\n", cat_id, mod1);
        return 1;
    }
    state_save(cat_id, mod1);
    return 0;
}

static int cmd_last(const char *base) {
    State s = state_load();
    if (s.cat == 0) { fprintf(stderr, "tl: 아직 읽은 모듈 없음\n"); return 1; }
    printf("\033[37m[%d-%d]\033[0m\n", s.cat, s.mod);
    if (print_mod(base, s.cat, s.mod) != 0) {
        fprintf(stderr, "tl: 저장된 모듈을 찾을 수 없음 (%d-%d)\n", s.cat, s.mod);
        return 1;
    }
    return 0;
}

static int cmd_next(const char *base) {
    State s = state_load();
    if (s.cat == 0) { fprintf(stderr, "tl: 아직 읽은 모듈 없음\n"); return 1; }
    int gi = global_idx(s.cat, s.mod) + 1;
    if (gi >= total_mods()) { printf("\033[37m마지막 모듈입니다.\033[0m\n"); return 0; }
    int cat_id, mod1;
    global_to_pos(gi, &cat_id, &mod1);
    printf("\033[37m[%d-%d]\033[0m\n", cat_id, mod1);
    state_save(cat_id, mod1);
    return print_mod(base, cat_id, mod1);
}

static int cmd_prev(const char *base) {
    State s = state_load();
    if (s.cat == 0) { fprintf(stderr, "tl: 아직 읽은 모듈 없음\n"); return 1; }
    int gi = global_idx(s.cat, s.mod) - 1;
    if (gi < 0) { printf("\033[37m첫 번째 모듈입니다.\033[0m\n"); return 0; }
    int cat_id, mod1;
    global_to_pos(gi, &cat_id, &mod1);
    printf("\033[37m[%d-%d]\033[0m\n", cat_id, mod1);
    state_save(cat_id, mod1);
    return print_mod(base, cat_id, mod1);
}

static void cmd_list(void) {
    printf("\033[1;33mavailable modules:\033[0m\n");
    for (int i = 0; i < g_ncat; i++) {
        Cat *c = &g_cats[i];
        printf("\n\033[1;33m%d. %s\033[0m\n", c->id, c->title);
        for (int j = 0; j < c->cnt; j++)
            printf("  \033[1;32m%d-%d  tl %s\033[0m\n", c->id, j+1, c->mods[j].name);
    }
}

/* ------------------------------------------------------------------ */
/* main                                                                 */
/* ------------------------------------------------------------------ */

int main(int argc, char *argv[]) {
    const char *dir = (access(MODULE_DIR_LOCAL, F_OK) == 0)
                      ? MODULE_DIR_LOCAL : MODULE_DIR;
    conf_load(dir);

    if (argc == 1) { cmd_index(dir); return 0; }

    const char *arg = argv[1];

    if (strcmp(arg, "list") == 0) { cmd_list(); return 0; }

    if (strcmp(arg, "help") == 0) {
        printf("\033[1;32mtl \033[37m<module>\033[0m    모듈 조회\n");
        printf("\033[1;32mtl \033[37m<n>\033[0m         카테고리 목록\n");
        printf("\033[1;32mtl \033[37m<n> <n>\033[0m     카테고리 내 모듈\n");
        printf("\033[1;32mtl z\033[0m         마지막으로 읽은 모듈\n");
        printf("\033[1;32mtl n\033[0m         다음 모듈\n");
        printf("\033[1;32mtl p\033[0m         이전 모듈\n");
        printf("\033[1;32mtl list\033[0m      전체 모듈 목록\n");
        return 0;
    }

    if (strcmp(arg, "z") == 0)                           return cmd_last(dir);
    if (strcmp(arg, "n") == 0 || strcmp(arg,"next") == 0) return cmd_next(dir);
    if (strcmp(arg, "p") == 0 || strcmp(arg,"prev") == 0) return cmd_prev(dir);

    /* 숫자: 카테고리 또는 tl N M */
    char *end;
    int n = (int)strtol(arg, &end, 10);
    if (*end == '\0') {
        if (argc >= 3) {
            int m = (int)strtol(argv[2], &end, 10);
            if (*end == '\0') return cmd_cat_mod(dir, n, m);
        }
        cmd_category(n);
        return 0;
    }

    /* 이름으로 탐색 */
    int cat_id;
    int mi = find_by_name(arg, &cat_id);
    if (mi >= 0) {
        state_save(cat_id, mi + 1);
        if (print_mod(dir, cat_id, mi + 1) != 0) {
            fprintf(stderr, "tl: '%s' 파일 없음 (모듈 미작성)\n", arg);
            return 1;
        }
        return 0;
    }

    fprintf(stderr, "tl: '\033[1m%s\033[0m' not found\n", arg);
    fprintf(stderr, "    \033[4;36mtl list\033[0m 로 모듈 목록 확인\n");
    return 1;
}
