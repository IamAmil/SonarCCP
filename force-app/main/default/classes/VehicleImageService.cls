public with sharing class VehicleImageService {
    public class ImageOutput {
        @AuraEnabled public String fileURL;
        @AuraEnabled public String fileName;
        @AuraEnabled public String filetype;
        @AuraEnabled public String Description;
    }

    public class GroupedImageOutput {
        @AuraEnabled public List<ImageOutput> Certificates = new List<ImageOutput>();
        @AuraEnabled public List<ImageOutput> Images = new List<ImageOutput>();
    }

    
    
    @AuraEnabled
    public static String getImagesAsBase64(String chassisNumber) {
        GroupedImageOutput groupedOutput = new GroupedImageOutput();
        System.debug('Chassis Number: ' + chassisNumber);
        try {
            // Query the vehicle record based on the chassis number
            List<ccp2_Registered_Vehicle__c> vehicles = [SELECT Id, Chassis_number__c FROM ccp2_Registered_Vehicle__c WHERE Chassis_number__c = :chassisNumber];
            if (vehicles.isEmpty()) {
                throw new AuraHandledException('No vehicle found with the provided chassis number.');
            }
            String vehicleId = vehicles[0].Id;
            System.debug('Vehicle ID: ' + vehicleId);

            // Query the ContentDocumentLink object to find all ContentDocuments associated with the vehicle ID
            List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :vehicleId];
            if (docLinks.isEmpty()) {
                throw new AuraHandledException('No documents found for the provided vehicle ID.');
            }
            System.debug('Document Links: ' + docLinks);

            // Extract the ContentDocument IDs
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink docLink : docLinks) {
                contentDocumentIds.add(docLink.ContentDocumentId);
            }
            System.debug('Content Document IDs: ' + contentDocumentIds);

            // Query all versions of the content documents
            List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, FileExtension, FileType, Description
                                                    FROM ContentVersion 
                                                    WHERE ContentDocumentId IN :contentDocumentIds 
                                                    ORDER BY LastModifiedDate DESC];
            if (contentVersions.isEmpty()) {
                throw new AuraHandledException('No content versions found for the documents.');
            }
            System.debug('Content Versions: ' + contentVersions);

            // Process each content version and convert it to base64
            for (ContentVersion contentVersion : contentVersions) {
                System.debug('Processing Content Version: ' + contentVersion);
                
                String base64Data = EncodingUtil.base64Encode(contentVersion.VersionData);
                String extensionName = String.valueOf(contentVersion.FileExtension);

                String imageURL = 'data:image/' + extensionName + ';base64,' + base64Data;

                ImageOutput output = new ImageOutput();
                output.description = contentVersion.Description;
                output.fileUrl = imageURL;
                output.fileName = contentVersion.Title;
                output.filetype = contentVersion.FileType;

                System.debug('Output: ' + output);

                if (contentVersion.Description == 'Images') {
                    groupedOutput.Certificates.add(output);
                } else if (contentVersion.Description == 'Certificates') {
                    groupedOutput.Images.add(output);
                }
            }

            System.debug('GroupedOutput before conditionals: ' + groupedOutput);

            // Convert the grouped result to JSON
            String jsonOutput = JSON.serialize(groupedOutput);
            System.debug('Grouped JSON Output: ' + jsonOutput);

            return jsonOutput;

        } catch (Exception e) {
            CCP2_HandlerForException.LogException(e);
            throw new AuraHandledException('An error occurred while retrieving the images: ' + e.getMessage());
        }
    }
}