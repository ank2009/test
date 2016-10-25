@isTest
private class TLR_FilePickerTest
{
    static testMethod void testFilePicker()
    {
        TLR_FilePicker objFilePicker 	= new TLR_FilePicker();
        objFilePicker.attachment.Name 	= 'Unit Test Attachment';
    	Blob bodyBlob			 		= Blob.valueOf('Unit Test Attachment Body');
    	objFilePicker.attachment.body 	= bodyBlob;
        objFilePicker.attachToEmail();
    }
}