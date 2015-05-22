
using namespace Cedar::Matchers;

SPEC_BEGIN(MemoryStorageSpecs)

describe(@"Storage search specs", ^{
    __block DTMemoryStorage *storage;
    
    beforeEach(^{
        storage = [DTMemoryStorage new];
        storage.delegate = [OCMockObject niceMockForClass:[DTTableViewController class]];
    });
    
    it(@"should correctly return item at indexPath", ^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        id model = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                    inSection:1]];
        
        model should equal(@"4");
        
        model = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        model should equal(@"1");
    });
    
    it(@"should return indexPath of tableItem", ^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        NSIndexPath * indexPath = [storage indexPathForItem:@"3"];
        
        indexPath should equal([NSIndexPath indexPathForRow:0 inSection:1]);
    });
    
    it(@"should return items in section",^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        NSArray * section0 = [storage itemsInSection:0];
        NSArray * section1 = [storage itemsInSection:1];
        
        section0 should equal(@[@"1",@"2"]);
        section1 should equal(@[@"3",@"4"]);
    });
    
});

describe(@"Storage Add specs", ^{
    __block DTMemoryStorage *storage;
    __block OCMockObject * delegate;

    beforeEach(^{
        delegate = [OCMockObject mockForClass:[DTTableViewController class]];
        storage = [DTMemoryStorage new];
        [storage setSupplementaryHeaderKind:DTTableViewElementSectionHeader];
        [storage setSupplementaryFooterKind:DTTableViewElementSectionFooter];
        storage.delegate = (id <DTStorageUpdating>)delegate;
    });
    
    it(@"should receive correct update call when adding table item",
    ^{
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.insertedSectionIndexes addIndex:0];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
            return [update isEqual:argument];
        }]];
        
        [storage addItem:@""];
        [delegate verify];
    });
    
    it(@"should receive correct update call when adding table items",
    ^{
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.insertedSectionIndexes addIndexesInRange:{0,2}];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:1]];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                   inSection:1]];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:2
                                                                   inSection:1]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
            return [update isEqual:argument];
        }]];
        
        [storage addItems:@[@"1",@"2",@"3"] toSection:1];
        [delegate verify];
    });
});

describe(@"Storage edit specs", ^{
    __block DTMemoryStorage *storage;
    __block OCMockObject * delegate;
    __block Example * acc1;
    __block Example * acc2;
    __block Example * acc3;
    __block Example * acc4;
    __block Example * acc5;
    __block Example * acc6;
    
    beforeEach(^{
        delegate = [OCMockObject niceMockForClass:[DTTableViewController class]];
        storage = [DTMemoryStorage new];
        [storage setSupplementaryHeaderKind:DTTableViewElementSectionHeader];
        [storage setSupplementaryFooterKind:DTTableViewElementSectionFooter];
        storage.delegate = (id <DTStorageUpdating>)delegate;
        
        acc1 = [Example new];
        acc2 = [Example new];
        acc3 = [Example new];
        acc4 = [Example new];
        acc5 = [Example new];
        acc6 = [Example new];
    });
    
    it(@"should insert table items", ^{
        [storage addItems:@[acc2,acc4,acc6]];
        [storage addItem:acc5 toSection:1];
        
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:2
                                                                   inSection:0]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
           return [update isEqual:obj];
        }]];
        
        [storage insertItem:acc1 toIndexPath:[storage indexPathForItem:acc6]];
        
        [delegate verify];
        
        update = [DTStorageUpdate new];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:1]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage insertItem:acc3 toIndexPath:[storage indexPathForItem:acc5]];
        
        [delegate verify];
    });
    
    it(@"should reload table view rows", ^{
        
        [storage addItems:@[acc2,acc4,acc6]];
        
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage reloadItem:acc4];
        
        [delegate verify];
    });
    
    it(@"should reload table view rows", ^{
        
        [storage addItems:@[acc2,acc4,acc6]];
        
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage replaceItem:acc4 withItem:acc5];
        
        [delegate verify];
    });
    
    it(@"should remove table item", ^{
        [storage addItems:@[acc2,acc4,acc6]];
        [storage addItem:acc5 toSection:1];
        
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:0]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeItem:acc2];
        [delegate verify];
        
        update = [DTStorageUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:1]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeItem:acc5];
        [delegate verify];
    });
    
    it(@"should remove table items", ^{
        [storage addItems:@[acc1,acc3] toSection:0];
        [storage addItems:@[acc2,acc4] toSection:1];
        
        
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                  inSection:0]];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:1]];
        [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage removeItems:@[acc1,acc4,acc3,acc5]];
        [delegate verify];
        
        [[storage itemsInSection:0] count] should equal(0);
        [[storage itemsInSection:1] count] should equal(1);
    });
    
    it(@"should delete sections", ^{
        [storage addItem:acc1];
        [storage addItem:acc2 toSection:1];
        [storage addItem:acc3 toSection:2];
        
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.deletedSectionIndexes addIndex:1];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        [storage deleteSections:[NSIndexSet indexSetWithIndex:1]];
        [delegate verify];
        
        [[storage sections] count] should equal(2);
    });
    
    
    it(@"should set section header models", ^{
        [storage setSectionHeaderModels:@[@"1",@"2",@"3"]];
        
        [[storage sections] count] should equal(3);
        
        [storage headerModelForSectionIndex:0] should equal(@"1");
        [storage headerModelForSectionIndex:1] should equal(@"2");
        [storage headerModelForSectionIndex:2] should equal(@"3");
    });
    
    it(@"should set section footer models", ^{
        [storage setSectionFooterModels:@[@"1",@"2",@"3"]];
        
        [[storage sections] count] should equal(3);
        
        [storage footerModelForSectionIndex:0] should equal(@"1");
        [storage footerModelForSectionIndex:1] should equal(@"2");
        [storage footerModelForSectionIndex:2] should equal(@"3");
    });
    
    it(@"should empty section headers if nil passed", ^{
        [storage setSectionHeaderModels:@[@"1",@"2",@"3"]];
        
        [storage setSectionHeaderModels:nil];
        
        expect([storage headerModelForSectionIndex:1] == nil).to(be_truthy);
    });
    
    it(@"should empty section headers if nil passed", ^{
        [storage setSectionHeaderModels:@[@"1",@"2",@"3"]];
        
        [storage setSectionHeaderModels:@[]];
        
        expect([storage headerModelForSectionIndex:1] == nil).to(be_truthy);
    });
    
    it(@"should empty section headers if nil passed", ^{
        [storage setSectionFooterModels:@[@"1",@"2",@"3"]];
        
        [storage setSectionFooterModels:nil];
        
        expect([storage footerModelForSectionIndex:1] == nil).to(be_truthy);
    });
    
    it(@"should empty section headers if nil passed", ^{
        [storage setSectionFooterModels:@[@"1",@"2",@"3"]];
        
        [storage setSectionFooterModels:@[]];
        
        expect([storage footerModelForSectionIndex:1] == nil).to(be_truthy);
    });
});


SPEC_END
