@isTest
public class CCP2_vehcileImageUploaderTest {
    
    @isTest
    static void testUploadImage_Success() {
        // Create a test vehicle record
        Account testVehicle = new Account(Name='Test Vehicle');
        insert testVehicle;

        // Create a valid JSON string with image input data
        String jsonString = '[{"filename":"testImage.png","base64":"iVBORw0KGgoAAAANSUhEUgAAAAUA","filetype":"image/png","fileURL":"testURL"}]';

        // Call the method and assert no exception is thrown
        Test.startTest();
        CCP2_vehcileImageUploader.uploadImage(jsonString, testVehicle.Id);
        Test.stopTest();

        // Verify that the ContentVersion record is created
        List<ContentVersion> contentVersions = [SELECT Id, Title, Description, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId = :testVehicle.Id];
        System.assertEquals(1, contentVersions.size(), 'ContentVersion record should be created.');
        System.assertEquals('testImage.png', contentVersions[0].Title, 'Filename should match.');
        System.assertEquals('image/png', contentVersions[0].Description, 'Filetype should match.');
    }

    @isTest
    static void testUploadImage_EmptyJSONString() {
        // Create a test vehicle record
        Account testVehicle = new Account(Name='Test Vehicle');
        insert testVehicle;

        // Create an empty JSON string
        String jsonString = '';

        // Call the method and assert an AuraHandledException is thrown
        try {
            Test.startTest();
            CCP2_vehcileImageUploader.uploadImage(jsonString, testVehicle.Id);
            Test.stopTest();
            System.assert(false, 'Expected AuraHandledException was not thrown.');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception message should match.');
        }
    }

    @isTest
    static void testUploadImage_InvalidBase64() {
        // Create a test vehicle record
        Account testVehicle = new Account(Name='Test Vehicle');
        insert testVehicle;

        // Create a JSON string with invalid base64 data
        String jsonString = '[{"filename":"testImage.png","base64":"invalidBase64Data","filetype":"image/png","fileURL":"testURL"}]';

        // Call the method and assert an exception is thrown
        try {
            Test.startTest();
            CCP2_vehcileImageUploader.uploadImage(jsonString, testVehicle.Id);
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('An error occurred while uploading the images'), 'Exception message should contain specific error message.');
        }
    }

    @isTest
    static void testUploadImage_MultipleImages() {
        // Create a test vehicle record
        Account testVehicle = new Account(Name='Test Vehicle');
        insert testVehicle;

        // Create a JSON string with multiple image inputs
        String jsonString = '[{"filename":"testImage1.png","base64":"iVBORw0KGgoAAAANSUhEUgAAAAUA","filetype":"image/png","fileURL":"testURL1"},' +
                            '{"filename":"testImage2.png","base64":"iVBORw0KGgoAAAANSUhEUgAAAAUA","filetype":"image/png","fileURL":"testURL2"}]';

        // Call the method and assert no exception is thrown
        Test.startTest();
        CCP2_vehcileImageUploader.uploadImage(jsonString, testVehicle.Id);
        Test.stopTest();

        // Verify that the ContentVersion records are created
        List<ContentVersion> contentVersions = [SELECT Id, Title, Description, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId = :testVehicle.Id];
        System.assertEquals(2, contentVersions.size(), 'ContentVersion records should be created.');
        System.assertEquals('testImage1.png', contentVersions[0].Title, 'First image filename should match.');
        System.assertEquals('image/png', contentVersions[0].Description, 'First image filetype should match.');
        System.assertEquals('testImage2.png', contentVersions[1].Title, 'Second image filename should match.');
        System.assertEquals('image/png', contentVersions[1].Description, 'Second image filetype should match.');
    }
    
    @isTest
    static void testDeleteContentDocumentByVersionId() {
        // Create a test ContentVersion record
        ContentVersion ver = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test Document.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert ver;

        // Get the ContentDocumentId from the inserted ContentVersion
        ver = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :ver.Id LIMIT 1];

        // Verify the ContentDocument exists
        System.assert([SELECT Id FROM ContentDocument WHERE Id = :ver.ContentDocumentId].size() > 0, 'ContentDocument should exist.');

        // Call the method and assert no exception is thrown
        Test.startTest();
        CCP2_vehcileImageUploader.deleteContentDocumentByVersionId(ver.Id);
        Test.stopTest();

        // Verify the ContentDocument record is deleted
        System.assert([SELECT Id FROM ContentDocument WHERE Id = :ver.ContentDocumentId].size() == 0, 'ContentDocument should be deleted.');
    }
    
    @isTest
    static void testUpdateFirstPublishLocationId() {
        // Create a test vehicle record
        Account testVehicle = new Account(Name='Test Vehicle');
        insert testVehicle;

        // Create another test vehicle record to update the LinkedEntityId to
        Account newVehicle = new Account(Name='New Test Vehicle');
        insert newVehicle;

        // Create a test ContentVersion record
        ContentVersion ver = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test Document.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert ver;

        // Get the ContentDocumentId from the inserted ContentVersion
        ver = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :ver.Id LIMIT 1];

        // Create a ContentDocumentLink for the original vehicle
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = ver.ContentDocumentId,
            LinkedEntityId = testVehicle.Id,
            ShareType = 'I'
        );
        insert link;

        // Verify the ContentDocumentLink exists
        System.assert([SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :ver.ContentDocumentId AND LinkedEntityId = :testVehicle.Id].size() > 0, 'ContentDocumentLink should exist.');

        // Create JSON string for the contentVersionIds
        List<String> contentVersionIds = new List<String> { ver.Id };
        String contentVersionIdsJson = JSON.serialize(contentVersionIds);

        // Call the method and assert no exception is thrown
        Test.startTest();
        CCP2_vehcileImageUploader.updateFirstPublishLocationId(contentVersionIdsJson, newVehicle.Id);
        Test.stopTest();

        // Verify the new ContentDocumentLink is created
        System.assert([SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :ver.ContentDocumentId AND LinkedEntityId = :newVehicle.Id].size() > 0, 'New ContentDocumentLink should be created.');
    }
}