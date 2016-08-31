//
//  LEOCachePolicy.m
//  Leo
//
//  Created by Adam Fanslau on 7/6/16.
//  Copyright © 2016 Leo Health. All rights reserved.
//

#import "LEOCachePolicy.h"

@implementation LEOCachePolicy

- (instancetype)initWithGet:(LEOCachePolicyGET)get
                        put:(LEOCachePolicyPUT)put
                       post:(LEOCachePolicyPOST)post
                    destroy:(LEOCachePolicyDESTROY)destroy {

    self = [super init];
    if (self) {
        _get = get;
        _put = put;
        _post = post;
        _destroy = destroy;
    }

    return self;
}

- (instancetype)init {

    return [self initWithGet:defaultGET
                         put:defaultPUT
                        post:defaultPOST
                     destroy:defaultDESTROY];
}

+ (instancetype)cacheOnly {
    return [[self alloc] initWithGet:LEOCachePolicyGETCacheOnly
                                 put:LEOCachePolicyPUTCacheOnly
                                post:LEOCachePolicyPOSTCacheOnly
                             destroy:LEOCachePolicyDESTROYCacheOnly];
}

+ (instancetype)networkOnly {
    return [[self alloc] initWithGet:LEOCachePolicyGETNetworkOnly
                                 put:LEOCachePolicyPUTNetworkOnly
                                post:LEOCachePolicyPOSTNetworkOnly
                             destroy:LEOCachePolicyDESTROYNetworkOnly];
}

@end
