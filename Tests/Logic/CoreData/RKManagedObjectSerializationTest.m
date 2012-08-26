#import "RKTestEnvironment.h"
#import "RKManagedObjectMapping.h"
#import "RKHuman.h"
#import "RKMappableObject.h"
#import "RKChild.h"
#import "RKParent.h"
#import "NSEntityDescription+RKAdditions.h"

@interface RKManagedObjectSerializationTest : RKTestCase

@end

@implementation RKManagedObjectSerializationTest

- (void)setUp
{
    [RKTestFactory setUp];
}

- (void)tearDown
{
    [RKTestFactory tearDown];
}

- (void)testShouldSerializeNilToJSON
{
    RKManagedObjectStore *store = [RKTestFactory managedObjectStore];
    [RKHuman truncateAllInContext:store.primaryManagedObjectContext];
    store.cacheStrategy = [RKInMemoryManagedObjectCache new];
    [RKHuman truncateAll];
    
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[RKHuman class] inManagedObjectStore:store];
    [mapping addAttributeMapping:[RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"]];
    [mapping addAttributeMapping:[RKObjectAttributeMapping mappingFromKeyPath:@"nickName" toKeyPath:@"nick_name"]];
    mapping.nilAttributeMappingMode = RKNilAttributeMappingModeNULL;
    
    RKHuman *human = [RKHuman object];
    human.name = @"Mike Zornek";
    human.nickName = nil;
    
    RKObjectSerializer *serializer = [RKObjectSerializer serializerWithObject:human mapping:mapping];
    NSError *error = nil;
    id<RKRequestSerializable> serialization = [serializer serializationForMIMEType:@"application/json" error:&error];
    NSString *data = [[[NSString alloc] initWithData:[serialization HTTPBody] encoding:NSUTF8StringEncoding] autorelease];
    data = [data stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    assertThat(error, is(nilValue()));
    assertThat(data, is(equalTo(@"{\"nick_name\":null,\"name\":\"Mike Zornek\"}")));
}

- (void)testShouldOmitNilWhenSerializingToJSON
{
    RKManagedObjectStore *store = [RKTestFactory managedObjectStore];
    [RKHuman truncateAllInContext:store.primaryManagedObjectContext];
    store.cacheStrategy = [RKInMemoryManagedObjectCache new];
    [RKHuman truncateAll];
    
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[RKHuman class] inManagedObjectStore:store];
    [mapping addAttributeMapping:[RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"]];
    [mapping addAttributeMapping:[RKObjectAttributeMapping mappingFromKeyPath:@"nickName" toKeyPath:@"nick_name"]];
    mapping.nilAttributeMappingMode = RKNilAttributeMappingModeOmit;
    
    RKHuman *human = [RKHuman object];
    human.name = @"Mike Zornek";
    human.nickName = nil;
    
    RKObjectSerializer *serializer = [RKObjectSerializer serializerWithObject:human mapping:mapping];
    NSError *error = nil;
    id<RKRequestSerializable> serialization = [serializer serializationForMIMEType:@"application/json" error:&error];
    NSString *data = [[[NSString alloc] initWithData:[serialization HTTPBody] encoding:NSUTF8StringEncoding] autorelease];
    data = [data stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    assertThat(error, is(nilValue()));
    assertThat(data, is(equalTo(@"{\"name\":\"Mike Zornek\"}")));
}

@end
