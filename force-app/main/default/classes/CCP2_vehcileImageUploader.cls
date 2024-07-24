public class CCP2_vehcileImageUploader {

    public class UploadImageInput {
        @AuraEnabled public String filename;
        @AuraEnabled public String base64;
        @AuraEnabled public String filetype;
        @AuraEnabled public String fileURL;
    }

    @AuraEnabled
    public static void uploadImage(String jsonStrings,String vehicleId) {
        try {
            if (String.isBlank(jsonStrings)) {
                throw new AuraHandledException('JSON string is empty or null.');
            }

            System.debug('Input JSON: ' + jsonStrings);

            // Deserialize JSON input into a list of UploadImageInput
            List<UploadImageInput> imageInputs = (List<UploadImageInput>) JSON.deserialize(jsonStrings, List<UploadImageInput>.class);
            
            System.debug('Deserialized Image Inputs: ' + imageInputs);

            //String vehicleId = vehicleId;
            //String vehicleId = 'a1aIo000000Gr8rIAC';
             
            List<ContentVersion> contentVersions = new List<ContentVersion>();

            // Process each image input
            for (UploadImageInput input : imageInputs) {
                System.debug('Processing Image Input: ' + input);
                
                // Decode base64Data
                Blob fileBody = EncodingUtil.base64Decode(input.base64);
                
                String fileUrl = Input.fileURL;
                System.debug(fileUrl);
                // Create a new ContentVersion record
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = input.filename;
                contentVersion.PathOnClient = input.filename;
                contentVersion.VersionData = fileBody;
                contentVersion.Description = input.filetype;
                contentVersion.FirstPublishLocationId = vehicleId;
                
                // Add to list for bulk insert
                contentVersions.add(contentVersion);
            }

            System.debug('Content Versions to Insert: ' + contentVersions);

            // Insert all ContentVersion records in one transaction
            insert contentVersions;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while uploading the images: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteContentDocumentByVersionId(String contentVersionId) {
        try {
            if (contentVersionId == null || contentVersionId == '') {
                throw new AuraHandledException('Content Version ID cannot be null or empty.');
            }
            ContentVersion contentVersion = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :contentVersionId 
                LIMIT 1
            ];
            System.debug(contentVersion);
            Id contentDocumentId = contentVersion.ContentDocumentId;
            ContentDocument contentDocument = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Id = :contentDocumentId 
                LIMIT 1
            ];
            System.debug(contentDocument);
            delete contentDocument;
            System.debug('ContentDocument record deleted successfully: ' + contentDocumentId);
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while deleting the ContentDocument record: ' + e.getMessage());
        }
    }
   @AuraEnabled
    public static void updateFirstPublishLocationId(String contentVersionIdsJson, String vehicleId) {
        try {
            // Deserialize the JSON string into a List<String>
            List<String> contentVersionIds = (List<String>) JSON.deserialize(contentVersionIdsJson, List<String>.class);

            // Validate the input
            if (contentVersionIds == null || contentVersionIds.isEmpty()) {
                throw new AuraHandledException('Content Version IDs cannot be null or empty.');
            }
            if (vehicleId == null || vehicleId == '') {
                throw new AuraHandledException('Vehicle ID cannot be null or empty.');
            }

            // Query existing ContentDocumentLinks
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT Id, ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds)
            ];

            // Collect ContentDocumentIds
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink link : contentDocumentLinks) {
                contentDocumentIds.add(link.ContentDocumentId);
            }

            // Create new ContentDocumentLinks with the new LinkedEntityId (Vehicle ID)
            List<ContentDocumentLink> newContentDocumentLinks = new List<ContentDocumentLink>();
            for (Id contentDocumentId : contentDocumentIds) {
                ContentDocumentLink newLink = new ContentDocumentLink();
                newLink.ContentDocumentId = contentDocumentId;
                newLink.LinkedEntityId = vehicleId;
                newLink.ShareType = 'I'; // Choose appropriate ShareType if necessary
                newContentDocumentLinks.add(newLink);
            }

            // Insert the new ContentDocumentLinks
            insert newContentDocumentLinks;

            // Optionally, you can add some logging or debug statements here
            System.debug('New ContentDocumentLink records created successfully.');

        } catch (Exception e) {
            // Handle any exceptions and provide a meaningful error message
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while updating the ContentDocumentLink records: ' + e.getMessage());
        }
    }
}