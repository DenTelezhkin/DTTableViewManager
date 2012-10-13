#import "DTCellFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DTCellFactorySpec)

describe(@"DTCellFactory", ^{

    it(@"class mapping dictionary should not be nil", ^{
        [DTCellFactory sharedInstance].classMappingDictionary should_not be_nil;
    });
    
    it(@"should set mapping", ^{
        [[DTCellFactory sharedInstance] addCellClassMapping:[@[] class]
                                                    forModel:@"123"];
        
        NSDictionary * mapping = [[DTCellFactory sharedInstance] classMappingDictionary];
        mapping should_not be_nil;
        [mapping objectForKey:NSStringFromClass([@"123" class])] should equal(NSStringFromClass([@[] class]));
    });

});

SPEC_END
