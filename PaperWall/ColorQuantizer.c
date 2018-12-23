//
//  ColorQuantizer.c
//  DNS
//
//  Created by WENTAO XING on 2018/12/7.
//  Copyright © 2018 WENTAO XING. All rights reserved.
//

#include "ColorQuantizer.h"
#include <stdlib.h>
#include <errno.h>
#define oops(m) {perror(m); exit(1);}
#define MAX_LENGTH 8

typedef struct ColorItem {
    uint64_t r;
    uint64_t g;
    uint64_t b;
    bool isLeaf;
    struct ColorItem ** children;
    uint64_t pixelCount;
    struct ColorItem * next;
} ColorNode;


static int leafNum = 0;
static ColorNode ** reducerArr;
static uint64_t R = 0, G = 0, B = 0;

void releaseNode(ColorNode * node) {
    ColorNode ** children = node->children;
    if (children != NULL) {
        for (int i = 0; i < 8; i++) {
            if (children[i] != NULL) releaseNode(children[i]);
        }
        free(children);
    }
    free(node);
}

ColorNode * createColorNode(uint32_t level) {
    ColorNode * node = (ColorNode *) malloc(sizeof(ColorNode));
    if (node == NULL) {
        oops("malloc: ");
    }
    node -> r = 0;
    node -> g = 0;
    node -> b = 0;
    node->pixelCount = 0;
    if (level == MAX_LENGTH) {
        node->isLeaf = true;
        node->children = NULL;
        leafNum++;
    } else {
        node->isLeaf = false;
        node->children = (ColorNode **) calloc(MAX_LENGTH, sizeof(ColorNode *));
        node->next = reducerArr[level];
        reducerArr[level] = node;
    }
    return node;
}

uint8_t getColorIndex(uint8_t r, uint8_t g, uint8_t b, uint32_t level) {
    uint8_t index = 0;
    uint8_t mask = 0x80 >> level;
    if (r & mask) index |= 0x04;
    if (g & mask) index |= 0x02;
    if (b & mask) index |= 0x01;
    return index;
}

void addColorNode(uint8_t r, uint8_t g, uint8_t b, ColorNode * node, uint32_t level) {
    if (node->isLeaf) {
        node->r += r;
        node->g += g;
        node->b += b;
        node->pixelCount += 1;
    } else {
        uint8_t index = getColorIndex(r, g, b, level);
        ColorNode * nextNode;
        if (node->children[index] == NULL) {
            node->children[index] = createColorNode(level + 1);
        }
        nextNode = node->children[index];
        addColorNode(r, g, b, nextNode, level + 1);
    }
}

void reducerTree() {
    uint32_t start = MAX_LENGTH - 1;
    ColorNode * reduceNode;
    while ((reduceNode = reducerArr[start]) == NULL) {
        start--;
    }
    
    reducerArr[start] = reduceNode->next;
    
    for (int i = 0; i < MAX_LENGTH; i++) {
        ColorNode * child = reduceNode->children[i];
        if (child != NULL) {
            reduceNode->r += child->r;
            reduceNode->g += child->g;
            reduceNode->b += child->b;
            reduceNode->pixelCount += child->pixelCount;
            reduceNode->isLeaf = true;
            leafNum--;
            free(child);
        }
    }
    
    free(reduceNode->children);
    leafNum++;
}


ColorNode * buildOctree(uint8_t * pixels, uint64_t len, uint32_t maxLeaf) {
    leafNum = 0;
    R = G = B = 0;
    reducerArr = (ColorNode **) calloc(MAX_LENGTH, sizeof(ColorNode *));
    ColorNode * root = createColorNode(0);
    for (int i = 0; i < len; i += 4) {
        addColorNode(pixels[i], pixels[i + 1], pixels[i + 2], root, 0);
        while(leafNum > maxLeaf) reducerTree();
    }
    return root;
}

void getLeafColor(ColorNode * node, QuantizedColor * rp) {
    if (node->isLeaf) {
        uint64_t pixelCount = node->pixelCount;
        ColorRGB * c = (ColorRGB *) calloc(1, sizeof(ColorRGB));
        c->r = node->r/pixelCount;
        c->g = node->g/pixelCount;
        c->b = node->b/pixelCount;
        c->pixelCount = pixelCount;
        rp->colors[rp->count] = c;
        rp->count++;
    } else {
        ColorNode ** children = node->children;
        if (children != NULL) {
            for (int i = 0; i < MAX_LENGTH; i++) {
                if (children[i] != NULL) getLeafColor(children[i], rp);
            }
            free(children);
        }
    }
    free(node);
}

QuantizedColor * getQuantizedColor(uint8_t * pixel, uint64_t len, uint32_t maxLeaf) {
    QuantizedColor * rp = (QuantizedColor *) calloc(1, sizeof(QuantizedColor));
    rp->count = 0;
    rp->colors = (ColorRGB **) calloc(maxLeaf, sizeof(ColorRGB *));
    ColorNode * root = buildOctree(pixel, len, maxLeaf);
    getLeafColor(root, rp);
    free(reducerArr);
    return rp;
}

void freeQuantizedColor(QuantizedColor * p) {
    int count = p -> count;
    for (int i = 0; i < count; i++) {
        ColorRGB * c = p->colors[i];
        if (c != NULL) free(c);
    }
    
    free(p->colors);
    free(p);
}

ColorNode * getMapColor(uint8_t r, uint8_t g, uint8_t b, uint32_t level, ColorNode * node) {
    uint8_t index = getColorIndex(r, g, b, level);
    ColorNode * nextNode = node->children[index];
    if (nextNode->isLeaf) {
        return nextNode;
    } else {
        return getMapColor(r, g, b, level+1, nextNode);
    }
}

uint8_t * getQuantizerRgbData(uint8_t * pixel, uint64_t len, uint32_t maxLeaf) {
    ColorNode * root = buildOctree(pixel, len, maxLeaf);
    uint8_t * p = (uint8_t *) calloc(len, sizeof(uint8_t));
    for (int i = 0; i < len; i += 4) {
        ColorNode * node = getMapColor(pixel[i], pixel[i+1], pixel[i+2], 0, root);
        uint64_t count = node->pixelCount;
        p[i] = node->r/count;
        p[i + 1] = node->g/count;
        p[i + 2] = node->b/count;
        p[i + 3] = 255;
    }
    
//    releaseNode(root);
    return p;
}



