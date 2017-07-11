#ifndef INODE_H
#define INODE_H

#include <fcntl.h>
#include <sys/stat.h>

#define NUM_BLOCKS 8

// Good default modes:
// - Directory: 040755
// - Regular file: 0100644

typedef struct inode {
    int refs; // references to this inode
    int mode; // permissions and file type
    time_t ctime; // creation time
    time_t mtime; // modification time
    int data[NUM_BLOCKS]; // each entry is a pnum
    int indirect_pum;
    int size; // bytes for file
} inode;

inode* make_inode();
void inode_init(inode* node, int mode);
void inode_set_data(inode* node, int pnum, int data_size);
int inode_write(inode* node, const char* buf, size_t bytes, off_t offset);
void print_inode(inode* node);
#endif
