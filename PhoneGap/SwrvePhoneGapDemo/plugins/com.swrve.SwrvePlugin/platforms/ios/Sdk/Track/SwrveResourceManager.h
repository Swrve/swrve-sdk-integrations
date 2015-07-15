/*
 * SWRVE CONFIDENTIAL
 *
 * (c) Copyright 2010-2014 Swrve New Media, Inc. and its licensors.
 * All Rights Reserved.
 *
 * NOTICE: All information contained herein is and remains the property of Swrve
 * New Media, Inc or its licensors.  The intellectual property and technical
 * concepts contained herein are proprietary to Swrve New Media, Inc. or its
 * licensors and are protected by trade secret and/or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from Swrve.
 */

/*
 * SwrveResource: A collection of attributes
 */
@interface SwrveResource : NSObject

@property (atomic, retain) NSDictionary* attributes;

/*
 * Create SwrveResource with given attributes
 */
- (id) init:(NSDictionary*)resourceAttributes;

/*
 * Gets an attribute of the resource as a string.
 * If the attribute is not available we return the defaultValue
 */
- (NSString*) getAttributeAsString:(NSString*)attributeId withDefault:(NSString*)defaultValue;

/*
 * Gets an attribute of the resource as an int.
 * If the attribute is not available we return the defaultValue
 */
- (int) getAttributeAsInt:(NSString*)attributeId withDefault:(int)defaultValue;

/*
 * Gets an attribute of the resource as a float.
 * If the attribute is not available we return the defaultValue
 */
- (float) getAttributeAsFloat:(NSString*)attributeId withDefault:(float)defaultValue;

/*
 * Gets an attribute of the resource as a boolean.
 * If the attribute is not available we return the defaultValue
 */
- (BOOL) getAttributeAsBool:(NSString*)attributeId withDefault:(BOOL)defaultValue;

@end



@interface SwrveResourceManager : NSObject

@property (atomic, readonly) NSDictionary* resources;

/**
 * Returns all resources as an NSDictionary
 */
- (NSDictionary*) getResources;

/*
 * Returns a resource identified by resourceId.
 * nil is returned if the resource doesn't exist.
 */
- (SwrveResource*) getResource:(NSString*)resourceId;

/*
 * Gets an attribute of a resource as a string
 * If the resource or attribute is not available we return the defaultValue
 */
- (NSString*) getAttributeAsString:(NSString*)attributeId ofResource:(NSString*)resourceId withDefault:(NSString*)defaultValue;

/*
 * Gets an attribute of a resource as an int
 * If the resource or attribute is not available we return the defaultValue
 */
- (int) getAttributeAsInt:(NSString*)attributeId ofResource:(NSString*)resourceId withDefault:(int)defaultValue;

/*
 * Gets an attribute of a resource as a float
 * If the resource or attribute is not available we return the defaultValue
 */
- (float) getAttributeAsFloat:(NSString*)attributeId ofResource:(NSString*)resourceId withDefault:(float)defaultValue;

/*
 * Gets an attribute of a resource as a BOOL
 * If the resource or attribute is not available we return the defaultValue
 */
- (BOOL) getAttributeAsBool:(NSString*)attributeId ofResource:(NSString*)resourceId withDefault:(BOOL)defaultValue;

@end
