#import "DTTableViewMemoryStorage.h"
#import "OCMock.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(DTTableViewMemoryStorageSpecs)

describe(@"DTTableViewMemoryStorage search specs", ^{
    __block DTTableViewMemoryStorage *storage;
    
    beforeEach(^{
        storage = [DTTableViewMemoryStorage storageWithDelegate:[OCMockObject niceMockForClass:[DTTableViewController class]]];
    });
    
    it(@"should correctly return item at indexPath", ^{
        [storage addTableItems:@[@"1",@"2"] toSection:0];
        [storage addTableItems:@[@"3",@"4"] toSection:1];
        
        id model = [storage tableItemAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                    inSection:1]];
        
        model should equal(@"4");
        
        model = [storage tableItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        model should equal(@"1");
    });
    
    it(@"should return indexPath of tableItem", ^{
        [storage addTableItems:@[@"1",@"2"] toSection:0];
        [storage addTableItems:@[@"3",@"4"] toSection:1];
        
        NSIndexPath * indexPath = [storage indexPathOfTableItem:@"3"];
        
        indexPath should equal([NSIndexPath indexPathForRow:0 inSection:1]);
    });
    
    it(@"should return items in section",^{
        [storage addTableItems:@[@"1",@"2"] toSection:0];
        [storage addTableItems:@[@"3",@"4"] toSection:1];
        
        NSArray * section0 = [storage tableItemsInSection:0];
        NSArray * section1 = [storage tableItemsInSection:1];
        
        section0 should equal(@[@"1",@"2"]);
        section1 should equal(@[@"3",@"4"]);
    });
    
});

describe(@"DTTableViewMemoryStorage Add specs", ^{
    __block DTTableViewMemoryStorage *storage;
    __block OCMockObject * delegate;

    beforeEach(^{
        delegate = [OCMockObject mockForClass:[DTTableViewController class]];
        storage = [DTTableViewMemoryStorage storageWithDelegate:(id <DTTableViewDataStorageUpdating>)delegate];
    });
    
    it(@"should receive correct update call when adding table item",
    ^{
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
    
    it(@"should receive correct update call when adding table items",
    ^{
        DTTableViewUpdate * update = [DTTableViewUpdate new];
        [update.insertedSectionIndexes addIndexesInRange:{0,2}];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:1]];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                   inSection:1]];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:2
                                                                   inSection:1]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
            return [update isEqual:argument];
        }]];
        
        [storage addTableItems:@[@"1",@"2",@"3"] toSection:1];
        [delegate verify];
    });
});

describe(@"DTTableViewMemoryStorage insert specs", ^{
    __block DTTableViewMemoryStorage *storage;
    __block OCMockObject * delegate;
    __block Example * acc1;
    __block Example * acc2;
    __block Example * acc3;
    __block Example * acc4;
    __block Example * acc5;
    __block Example * acc6;
    
    beforeEach(^{
        delegate = [OCMockObject niceMockForClass:[DTTableViewController class]];
        storage = [DTTableViewMemoryStorage storageWithDelegate:(id <DTTableViewDataStorageUpdating>)delegate];
        
        acc1 = [Example new];
        acc2 = [Example new];
        acc3 = [Example new];
        acc4 = [Example new];
        acc5 = [Example new];
        acc6 = [Example new];
    });
    
    it(@"should insert table items", ^{
        [storage addTableItems:@[acc2,acc4,acc6]];
        [storage addTableItem:acc5 toSection:1];
        
        DTTableViewUpdate * update = [DTTableViewUpdate new];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:2
                                                                   inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
           return [update isEqual:obj];
        }]];
        
        [storage insertTableItem:acc1 toIndexPath:[storage indexPathOfTableItem:acc6]];
        
        [delegate verify];
        
        update = [DTTableViewUpdate new];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:1]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage insertTableItem:acc3 toIndexPath:[storage indexPathOfTableItem:acc5]];
        
        [delegate verify];
    });
    
    it(@"should reload table view rows", ^{
        
        [storage addTableItems:@[acc2,acc4,acc6]];
        
        DTTableViewUpdate * update = [DTTableViewUpdate new];
        [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage reloadTableItem:acc4];
        
        [delegate verify];
    });
    
    it(@"should reload table view rows", ^{
        
        [storage addTableItems:@[acc2,acc4,acc6]];
        
        DTTableViewUpdate * update = [DTTableViewUpdate new];
        [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage replaceTableItem:acc4 withTableItem:acc5];
        
        [delegate verify];
    });
    
    it(@"should remove table item", ^{
        [storage addTableItems:@[acc2,acc4,acc6]];
        [storage addTableItem:acc5 toSection:1];
        
        DTTableViewUpdate * update = [DTTableViewUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:0]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeTableItem:acc2];
        [delegate verify];
        
        update = [DTTableViewUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:1]];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeTableItem:acc5];
        [delegate verify];
    });
    
    it(@"should remove table items", ^{
        [storage addTableItems:@[acc1,acc3] toSection:0];
        [storage addTableItems:@[acc2,acc4] toSection:1];
        
        
        DTTableViewUpdate * update = [DTTableViewUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:0]];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:1]];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeTableItems:@[acc1,acc4,acc3,acc5]];
        [delegate verify];
        
        [[storage tableItemsInSection:0] count] should equal(0);
        [[storage tableItemsInSection:1] count] should equal(1);
    });
});


SPEC_END
