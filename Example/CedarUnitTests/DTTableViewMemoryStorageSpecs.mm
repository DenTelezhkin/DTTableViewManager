#import "DTTableViewMemoryStorage.h"
#import "OCMock.h"
#import "DTTableViewSectionModel.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(MemoryStorageSpecs)

describe(@"Storage search specs", ^{
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

describe(@"Storage Add specs", ^{
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

describe(@"Storage edit specs", ^{
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
    
    it(@"should delete sections", ^{
        [storage addTableItem:acc1];
        [storage addTableItem:acc2 toSection:1];
        [storage addTableItem:acc3 toSection:2];
        
        DTTableViewUpdate * update = [DTTableViewUpdate new];
        [update.deletedSectionIndexes addIndex:1];
        
        [[delegate expect] performUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage deleteSections:[NSIndexSet indexSetWithIndex:1]];
        [delegate verify];
        
        [[storage sections] count] should equal(2);
    });
    
    it(@"should set section header titles", ^{
        [storage setSectionHeaderTitles:@[@"1",@"2",@"3"]];
        
        [[storage sections] count] should equal(3);
        
        [[storage sections][0] headerTitle] should equal(@"1");
        [[storage sections][1] headerTitle] should equal(@"2");
        [[storage sections][2] headerTitle] should equal(@"3");
    });
    
    it(@"should set section header models", ^{
        [storage setSectionHeaderModels:@[@"1",@"2",@"3"]];
        
        [[storage sections] count] should equal(3);
        
        [[storage sections][0] headerModel] should equal(@"1");
        [[storage sections][1] headerModel] should equal(@"2");
        [[storage sections][2] headerModel] should equal(@"3");
    });
    
    it(@"should set section footer titles", ^{
        [storage setSectionFooterTitles:@[@"1",@"2",@"3"]];
        
        [[storage sections] count] should equal(3);
        
        [[storage sections][0] footerTitle] should equal(@"1");
        [[storage sections][1] footerTitle] should equal(@"2");
        [[storage sections][2] footerTitle] should equal(@"3");
    });
    
    it(@"should set section footer models", ^{
        [storage setSectionFooterModels:@[@"1",@"2",@"3"]];
        
        [[storage sections] count] should equal(3);
        
        [[storage sections][0] footerModel] should equal(@"1");
        [[storage sections][1] footerModel] should equal(@"2");
        [[storage sections][2] footerModel] should equal(@"3");
    });
});


SPEC_END
