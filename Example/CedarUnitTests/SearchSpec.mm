#import "DTTableViewManager.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(SearchSpec)

describe(@"search in first section", ^{
    __block DTTableViewManager *model;
    __block Example * acc1;
    __block Example * acc2;
    __block Example * acc3;
    __block Example * acc4;
    __block Example * acc5;
    __block Example * acc6;
    
    beforeEach(^{
        acc1 = [Example exampleWithText:@"London" andDetails:@"England"];
        acc2 = [Example exampleWithText:@"Tokyo" andDetails:@"Japan"];
        acc3 = [Example exampleWithText:@"Kyiv" andDetails:@"Ukraine"];
        acc4 = [Example exampleWithText:@"Moscow" andDetails:@"Russia"];
        acc5 = [Example exampleWithText:@"Washington D.C." andDetails:@"USA"];
        acc6 = [Example exampleWithText:@"Lissabon" andDetails:@"Portugal"];
        
        model = [DTTableViewManager new];
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        [model addTableItems:@[acc1,acc2,acc3,acc4,acc5,acc6]];
    });
    
    afterEach(^{
        [model release];
    });
    
    it(@"should find 2 items with double s", ^{
        [model filterTableItemsForSearchString:@"ss" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(2));
        
        expect([[[model tableItemsInSection:0] lastObject] text]).to(equal(@"Lissabon"));
    });
    
    it(@"should find none items for iva", ^{
        [model filterTableItemsForSearchString:@"iva" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(0));
    });
    
    it(@"should find 1 item for cow", ^{
        [model filterTableItemsForSearchString:@"cow" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[[model tableItemsInSection:0] lastObject] text]).to(equal(@"Moscow"));
    });
    
    it(@"should find 1 item for white space", ^{
        [model filterTableItemsForSearchString:@" " inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[[model tableItemsInSection:0] lastObject] text]).to(equal(@"Washington D.C."));
    });
    
    it(@"should find 1 item for .", ^{
        [model filterTableItemsForSearchString:@"." inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[[model tableItemsInSection:0] lastObject] text]).to(equal(@"Washington D.C."));
    });
    
    it(@"should find all items for empty search string", ^{
        [model filterTableItemsForSearchString:@"." inScope:0];
        
        [model filterTableItemsForSearchString:@"" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(6));
    });
    
    it(@"should find rai items", ^{
        [model filterTableItemsForSearchString:@"rai" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
    });
    
    
});

describe(@"search in multiple sections", ^{
    __block DTTableViewManager *model;
    __block Example * acc1;
    __block Example * acc2;
    __block Example * acc3;
    __block Example * acc4;
    __block Example * acc5;
    __block Example * acc6;
    
    beforeEach(^{
        acc1 = [Example exampleWithText:@"London" andDetails:@"England"];
        acc2 = [Example exampleWithText:@"Tokyo" andDetails:@"Japan"];
        
        acc3 = [Example exampleWithText:@"Kyiv" andDetails:@"Ukraine"];
        acc4 = [Example exampleWithText:@"Moscow" andDetails:@"Russia"];
        
        acc5 = [Example exampleWithText:@"Washington D.C." andDetails:@"USA"];
        acc6 = [Example exampleWithText:@"Lissabon" andDetails:@"Portugal"];
        
        model = [DTTableViewManager new];
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        model.tableView.delegate = model;
        model.tableView.dataSource = model;
        
        [model addTableItems:@[acc1,acc2] toSection:0];
        [model addTableItems:@[acc3,acc4] toSection:0];
        [model addTableItems:@[acc5,acc6] toSection:0];
    });
    
    afterEach(^{
        [model release];
    });
    
    it(@"should have correct search results for L symbol", ^{
        [model filterTableItemsForSearchString:@"L" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[model tableItemsInSection:0] lastObject]).to(equal(acc1));
        
        expect([[model tableItemsInSection:1] count]).to(equal(0));
        
        expect([[model tableItemsInSection:2] count]).to(equal(1));
        
        expect([[model tableItemsInSection:0] lastObject]).to(equal(acc6));
    });
    
    it(@"should have correct search results for y symbol", ^{
        [model filterTableItemsForSearchString:@"y" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(1));
        
        expect([[model tableItemsInSection:0] lastObject]).to(equal(acc2));
        
        expect([[model tableItemsInSection:1] count]).to(equal(1));
        
        expect([[model tableItemsInSection:1] lastObject]).to(equal(acc3));
        
        expect([[model tableItemsInSection:2] count]).to(equal(0));
    });
    
    it(@"should have all items for a query", ^{
        [model filterTableItemsForSearchString:@"a" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(2));
        
        expect([[model tableItemsInSection:1] count]).to(equal(2));
        
        expect([[model tableItemsInSection:2] count]).to(equal(2));
    });
    
    it(@"should have nothing for ost", ^{
        [model filterTableItemsForSearchString:@"ost" inScope:0];
        
        expect([[model tableItemsInSection:0] count]).to(equal(0));
        
        expect([[model tableItemsInSection:1] count]).to(equal(0));
        
        expect([[model tableItemsInSection:2] count]).to(equal(0));
    });
    
});

SPEC_END
