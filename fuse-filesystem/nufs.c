#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <sys/stat.h>
#include <dirent.h>
#include <bsd/string.h>
#include <assert.h>


#define FUSE_USE_VERSION 26
#include <fuse.h>
#include "storage.h"

// implementation for: man 2 access
// Checks if a file exists.
int nufs_access(const char *path, int mask)
{
    printf("access(%s, %04o)\n", path, mask);
    return 0;
}

// implementation for: man 2 stat
// gets an object's attributes (type, permissions, size, etc)
int nufs_getattr(const char *path, struct stat *st)
{
    printf("getattr(%s)\n", path);
    int rv = get_stat(path, st);
    printf("getattr(%s) -> %d\n", path, rv);
    
    if (rv == -1) {
        return -ENOENT;
    }
    else {
        return 0;
    }
}

// implementation for: man 2 readdir
// lists the contents of a directory
int nufs_readdir(const char *path, void *buf, fuse_fill_dir_t filler,
             off_t offset, struct fuse_file_info *fi)
{
    printf("readdir(%s)\n", path);
    return storage_readdir(path, buf, filler, offset);
}

// mknod makes a filesystem object like a file or directory
// called for: man 2 open, man 2 link
int nufs_mknod(const char *path, mode_t mode, dev_t rdev)
{
    printf("mknod(%s, %04o)\n", path, mode);
    return storage_mknod(path, mode);
}

// most of the following callbacks implement
// another system call; see section 2 of the manual
int nufs_mkdir(const char *path, mode_t mode)
{
    printf("mkdir(%s, %d)\n", path, mode);
    return storage_mkdir(path, mode);
}

// see man 2 link
int nufs_link(const char *from, const char *to)
{
    int rv = storage_link(from, to);
    printf("link(%s, %s) -> %d\n", from, to, rv);
    return rv;
}

// see man 2 unlink
// deletes files if there are no more references
int nufs_unlink(const char *path)
{
    int rv = storage_unlink(path);
    printf("unlink(%s) -> %d\n", path, rv);
    return rv;
}

// removes the directory
int nufs_rmdir(const char *path)
{
    printf("rmdir(%s)\n", path);
    return storage_rmdir(path);
}

// implements: man 2 rename
// called to move a file within the same filesystem
int nufs_rename(const char *from, const char *to)
{
    int rv = storage_rename(from, to);
    printf("rename(%s => %s) -> %d\n", from, to, rv);
    return 0;
}

int nufs_chmod(const char *path, mode_t mode)
{
    int rv = storage_chmod(path, mode);
    printf("chmod(%s, %04o) -> %d\n", path, mode, rv);
    return rv;
}

int nufs_truncate(const char *path, off_t size)
{
    int rv = storage_truncate(path, size);
    printf("truncate(%s, %ld bytes) -> %d\n", path, size, rv);
    return rv;
}

// this is called on open, but doesn't need to do much
// since FUSE doesn't assume you maintain state for
// open files.
int nufs_open(const char *path, struct fuse_file_info *fi)
{
    printf("open(%s)\n", path);
    return nufs_access(path, 0);
}

// Actually read data
int nufs_read(const char *path, char *buf, size_t size, off_t offset, 
        struct fuse_file_info *fi)
{
    printf("read(%s, %ld bytes, @%ld)\n", path, size, offset);
    const char* data = get_data(path);

    if (data == 0) {
        return 0;
    }

    int len = strlen(data) + 1;
    if (size < len) {
        len = size;
    }

    strncpy(buf, data, len); //changed from strlcpy
    return len;
}

// Actually write data
int nufs_write(const char *path, const char *buf, size_t size, off_t offset, 
        struct fuse_file_info *fi)
{
    printf("write(%s, %ld bytes, @%ld)\n", path, size, offset);
    int rv = storage_write(path, buf, size, offset);
    printf("write(%s, %ld bytes, @%ld) -> %d\n", path, size, offset, rv);
    return rv;
}

// Updates the timestamp on a file or directory
int nufs_utimens(const char* path, const struct timespec ts[2])
{
    int rv = storage_utimens(path, ts);
    printf("utimens(%s) -> %d\n", path, rv);
    return 0;
}

void nufs_init_ops(struct fuse_operations* ops)
{
    memset(ops, 0, sizeof(struct fuse_operations));
    ops->access   = nufs_access;
    ops->getattr  = nufs_getattr;
    ops->readdir  = nufs_readdir;
    ops->mknod    = nufs_mknod;
    ops->mkdir    = nufs_mkdir;
    ops->link     = nufs_link;
    ops->unlink   = nufs_unlink;
    ops->rmdir    = nufs_rmdir;
    ops->rename   = nufs_rename;
    ops->chmod    = nufs_chmod;
    ops->truncate = nufs_truncate;
    ops->open	  = nufs_open;
    ops->read     = nufs_read;
    ops->write    = nufs_write;
    ops->utimens  = nufs_utimens;
};

struct fuse_operations nufs_ops;

int main(int argc, char *argv[])
{
    assert(argc > 2);
    storage_init(argv[--argc]);
    nufs_init_ops(&nufs_ops);
    return fuse_main(argc, argv, &nufs_ops, NULL);
}

