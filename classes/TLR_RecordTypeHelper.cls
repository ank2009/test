/**
* @author		Brian Kessler (Brian_Kessler@epam.com)
* @date			2013 June 26
* @description	Methods to assist working with Record Types
* 		
*/
public class TLR_RecordTypeHelper 
{

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 17
	* @description	Method to get recordType Name Map.
	* @param		Set<Id> recordTypeNameSet
	* @return		Map<Id, String>
	**/	
	public static Map<Id, String> getNameMap (Set<Id> recordTypeNameSet)
	{
		List<RecordType> recordTypeList = [
											SELECT id, name
											FROM RecordType
											WHERE id IN :recordTypeNameSet
										];
										
		Map<Id, String> nameMap = new Map<Id, String>();
		for (RecordType recordType : recordTypeList)
		{
			nameMap.put (recordType.id, recordType.name);
		}
		 										
		return null;
	}

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 17
	* @description	Method to get recordType Name.
	* @param		Id : Id of record type
	* @return		String : Name
	**/	
	public static String getName (Id recordTypeId) 		 
	{ 
		return getNameMap (new Set<Id>{recordTypeId} )
				.get(recordTypeId);   
	} 

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 17
	* @description	Method to get recordType Name.
	* @param		RecordType recordType
	* @return		String : Name
	* @return		Id
	**/	
	public static String getName (RecordType recordType) {  return getName(recordType.id); }

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to get recordType Id.
	* @param		String sObjectName : Name of the relevant sObject.
	* @param		String typeName : Name of the relevant recordType.
	* @return		Id
	**/	
	public static Id getId (String sObjectName, String typeName)
	{
		return  Schema.getGlobalDescribe()
					  .get(sObjectName)
					  .getDescribe()
					  .getRecordTypeInfosByName()
					  .get(typeName)
					  .getRecordTypeId();  
	}
	
	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 27
	* @description	Method to get recordType Map of RecordType Ids, mapped to sObject names.
	* @param		Map<String, String> recordObjectTypeMap; whereas
	* 				 the first string is the sObject name, and 
	* 				 the second string is the corresponding desired recordType name.
	* @return		Map<String, Id>; whereas
	* 				 the first string is the sObject name, and 
	* 				 the second string is the corresponding desired recordType id.
	**/	
	public static Map<String, Id> getIdMap (Map<String, String> recordObjectTypeMap)
	{
		Map<String, Id> recordObjectIdMap = new Map<String, String>();

		for (String objectType : recordObjectTypeMap.keySet())
		{
			recordObjectIdMap.put (objectType, getId(objectType, recordObjectTypeMap.get(objectType)));
		}		
		
		return recordObjectIdMap;
	}
	
}