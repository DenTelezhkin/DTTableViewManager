#import "DTTableViewMemoryStorage.h"
#import "OCMock.h"

SPEC_BEGIN(DTTableViewMemoryStorageSpecs)

describe(@"DTTableViewMemoryStorageSpecs", ^{
    __block DTTableViewMemoryStorage *storage;
    __block OCMockObject * delegate;

    beforeEach(^{
        delegate = [OCMockObject mockForClass:[DTTableViewController class]];
        storage = [DTTableViewMemoryStorage storageWithDelegate:(id <DTTableViewDataStorageUpdating>)delegate];
    });
    
    it(@"should receive correct update call when adding table item", ^{
        
        DTTableViewUpdate * update = [DTTableViewUpdate new];
        [update.insertedSectionIndexes addIndex:0];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
            return [update isEqual:argument];
        }]];
        
        [storage addTableItem:@""];
        [delegate verify];
    });
});

SPEC_END
