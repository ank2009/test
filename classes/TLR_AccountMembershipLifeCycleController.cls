public without sharing class TLR_AccountMembershipLifeCycleController 
{   
    /*---------------This wrapper class used for visual showing of state Products-----*/
    public class ColorBox implements Comparable
    {
        public ColorBox(string name, integer weight)
        {
            CssClass = 'Color'+String.valueOf(weight);
            BoxName = name;
            BoxLabel = colorLabel.get(CssClass);
            ProdWeight = weight;
        }
        public ColorBox(string css, string name)
        {
            CssClass = css;
            BoxLabel = colorLabel.get(CssClass);
            BoxName = name;
            if(CssClass.containsAny('0123456789'))
                ProdWeight = Integer.valueOf(CssClass.substringAfter('r'));
        }
        public void MergerBoxes(ColorBox box)
        {
            if(box.ProdWeight > this.ProdWeight)
            {
                this.CssClass = box.CssClass;
                this.BoxName = box.BoxName;
                this.BoxLabel = box.BoxLabel;
                this.ProdWeight = box.ProdWeight;
            }
        }
        public void MergeSmallBoxes(ColorBox box)
        {
            if(this.CssClass != 'darkGreyBox') 
            {
                this.CssClass = box.CssClass;
            }
        }
        public Integer ProdWeight;
        public String CssClass { get; set; }
        public String BoxName { get; set; }
        public string BoxLabel { get; set; }
        private Map<String,String> colorLabel = new Map<String, String> { 'Color11' => 'Customer', 'Color10' => 'Free Member',
                                                                      'Color9' => 'Trial',
                                                                      'Color8' => 'Cancelled Member','Color7' => 'On notice Member',
                                                                      'Color6' => 'Expired Trial','Color5' => 'Cancelled Trial',
                                                                      'Color4' => 'Prospect','Color3' => 'Suspect',
                                                                      'Color2' => 'Postponed Prospect','Color1' => 'Out of target'};
        public integer compareTo(Object obj)
        {           
           if(this.ProdWeight > ((ColorBox)obj).ProdWeight)
               return -1;
           else if(this.ProdWeight < ((ColorBox)obj).ProdWeight)
               return 1;
           return 0;
        }                                                              
    }
    
    private ID accId { get; set; }
    private Map<String,List<Opportunity>> mapProductOppWithOffer { get; set; } // Map with values <Base Product Name, List of Opportunity
    private List<Subscription__c> lstSubs { get; set; } // All account subscriptions
    private Map<ID, Double> subscriptionPrice { get; set; } // Map with calculated summ for Price of the Current Fees. Key - Subscription ID
    public Map<String,ColorBox> productFamilyBoxes { set; get; } // Map for storing and shoing Product Family boxes
    public Map<String, List<ColorBox>> productBoxes { set; get; } // Map for sub-products
    private Map<ID, List<String>> subCurName  { set; get; } //Map for storing Subscription Current Fees Names. Key - Subscription ID
    private Map<ID, List<String>> subExpiredCurName  { set; get; } //Map for storing Subscription Expired Current Fees Names. Key - Subscription ID
    private final string ptv1 = 'Integrated km calculation Europe (PTV 1)';
    private final string ptv2 = 'Integrated km calculation Europe with cartography (PTV 2)';
    private boolean isPTVAdded = false; // Flag for PTV. If true - PTV already added
    private Subscription__c subBeforeUpdate {get;set;}
    
    public TLR_AccountMembershipLifeCycleController(ApexPages.StandardController controller)
    {
        this.accId = controller.getId();
        Map<String, Product_Mapping__c> prodMap = Product_Mapping__c.getAll();
        productFamilyBoxes = new Map<String,ColorBox>();
        productBoxes = new Map<String,List<ColorBox>>();
        Account acc = [Select PLC_CD__c, PLC_FX__c, PLC_TW__c, PLC_TAS__c,PLC_Support__c, PLC_TFC__c,PLC_Spot_Bidding__c,
                       PLC_CD_Summary__c, PLC_FX_Summary__c, PLC_TW_Summary__c, PLC_TAS_Summary__c,PLC_Support_Summary__c,PLC_TFC_Summary__c,PLC_Spot_Summary__c,
                       PLC_CD_Parent__c, PLC_FX_Parent__c, PLC_TW_Parent__c, PLC_TAS_Parent__c,PLC_Support_Parent__c,PLC_TFC_Parent__c,PLC_Spot_Bidding_Parent__c
                       From Account Where Id =: this.accId];
        for(Product_Mapping__c item: prodMap.values())
        {
            if(!productFamilyBoxes.containsKey(item.Product_Family__c))
            {
                if(item.Product_Family__c == 'CD')
                {
                    productFamilyBoxes.put(item.Product_Family__c, parsePLCFieldForFamily(acc.PLC_CD__c, acc.PLC_CD_Parent__c,'CD'));
                }
                else if(item.Product_Family__c == 'FX')
                {
                    productFamilyBoxes.put(item.Product_Family__c, parsePLCFieldForFamily(acc.PLC_FX__c, acc.PLC_FX_Parent__c,'FX'));
                }
                else if(item.Product_Family__c == 'TAS')
                {
                    productFamilyBoxes.put(item.Product_Family__c, parsePLCFieldForFamily(acc.PLC_TAS__c, acc.PLC_TAS_Parent__c,'TAS'));
                }
                else if(item.Product_Family__c == 'Support')
                {
                    productFamilyBoxes.put(item.Product_Family__c, parsePLCFieldForFamily(acc.PLC_Support__c, acc.PLC_Support_Parent__c,'Support'));
                }
                else if(item.Product_Family__c == 'TW')
                {
                    productFamilyBoxes.put(item.Product_Family__c, parsePLCFieldForFamily(acc.PLC_TW__c, acc.PLC_TW_Parent__c,'TW'));
                }
                else if(item.Product_Family__c == 'TFC')
                {
                    productFamilyBoxes.put(item.Product_Family__c, parsePLCFieldForFamily(acc.PLC_TFC__c, acc.PLC_TFC_Parent__c,'TFC'));
                }
                else if(item.Product_Family__c == 'Spot Bidding')
                {
                    productFamilyBoxes.put(item.Product_Family__c, parsePLCFieldForFamily(acc.PLC_Spot_Bidding__c, acc.PLC_Spot_Bidding_Parent__c,'Spot Bidding'));
                }
                productBoxes.put(item.Product_Family__c, new List<ColorBox>());
            }
      }
      for(Product_Mapping__c item: prodMap.values())
      {
            if(item.Product_Family__c == 'CD')
            {
                productBoxes.get(item.Product_Family__c).add(parsePLCFieldForProduct(acc.PLC_CD__c,acc.PLC_CD_Parent__c, item.Product_Full_Name__c));
            }
            else if(item.Product_Family__c == 'TW')
            {
                productBoxes.get(item.Product_Family__c).add(parsePLCFieldForProduct(acc.PLC_TW__c, acc.PLC_TW_Parent__c, item.Product_Full_Name__c));
            }
            else if(item.Product_Family__c == 'FX' && item.Name != 'FX')
            {
                productBoxes.get(item.Product_Family__c).add(parsePLCFieldForProduct(acc.PLC_FX__c, acc.PLC_FX_Parent__c, item.Product_Full_Name__c));
            }
            else if(item.Product_Family__c == 'TAS')
            {
                productBoxes.get(item.Product_Family__c).add(parsePLCFieldForProduct(acc.PLC_TAS__c, acc.PLC_TAS_Parent__c, item.Product_Full_Name__c));
            }
            else if(item.Product_Family__c == 'Support')
            {
                productBoxes.get(item.Product_Family__c).add(parsePLCFieldForProduct(acc.PLC_Support__c, acc.PLC_Support_Parent__c, item.Product_Full_Name__c));
            }
            else if(item.Product_Family__c == 'TFC')
            {
                productBoxes.get(item.Product_Family__c).add(parsePLCFieldForProduct(acc.PLC_TFC__c, acc.PLC_TFC_Parent__c, item.Product_Full_Name__c));
            }
            else if(item.Product_Family__c == 'Spot Bidding')
            {
                productBoxes.get(item.Product_Family__c).add(parsePLCFieldForProduct(acc.PLC_Spot_Bidding__c, acc.PLC_Spot_Bidding_Parent__c, item.Product_Full_Name__c));
            }
        }
    }
    
    public TLR_AccountMembershipLifeCycleController(string accountId)
    {
        Init(accountId, null);
    }
    
    public TLR_AccountMembershipLifeCycleController(string accountId, Subscription__c sub)
    {
        Init(accountId, sub);
    }
    
    private void Init(string accountId, Subscription__c sub)
    {
        if(General_Settings__c.getInstance('Default').Enable_PLC_Update__c)
        {
            this.accId = accountId;
            Account acc = [Select Id,PLC_CD__c,PLC_FX__c,PLC_TAS__c,PLC_Support__c,PLC_TW__c, PLC_Spot_Bidding__c, ALC__c From Account Where Id =: this.accId Limit 1];
            subscriptionPrice = new Map<ID, Double>();
            lstSubs = new List<Subscription__c>();
            if(sub != null)
            {
                subBeforeUpdate = sub;
            }
            Map<String, Product_Mapping__c> prodMap = Product_Mapping__c.getAll();
            productFamilyBoxes = new Map<String,ColorBox>();
            subCurName = new Map<ID, List<String>>();
            subExpiredCurName = new Map<ID, List<String>>();
            this.getAllData();
            for(Product_Mapping__c item: prodMap.values())
            {
                if(!productFamilyBoxes.containsKey(item.Product_Family__c))
                {
                    if(item.Product_Family__c == 'CD')
                    {
                        productFamilyBoxes.put(item.Product_Family__c, this.ComputeColorForProductCD(item));
                    }
                    else
                    {
                        productFamilyBoxes.put(item.Product_Family__c, this.ComputeColorForProductFamily(item));
                    }
                }
                else
                {
                    if(item.Product_Family__c == 'CD')
                    {
                        productFamilyBoxes.get(item.Product_Family__c).MergerBoxes(this.ComputeColorForProductCD(item));
                    }
                    else
                    {
                        productFamilyBoxes.get(item.Product_Family__c).MergerBoxes(this.ComputeColorForProductFamily(item));
                    }
                }
          }
          for(ColorBox box :productFamilyBoxes.values())
          {
            if(box.BoxName == 'CD')
            {
                acc.PLC_CD__c = box.BoxLabel + '-'+ box.CssClass +'; ';
            } 
            else if(box.BoxName == 'FX')
            {
                acc.PLC_FX__c = box.BoxLabel  + '-'+ box.CssClass +'; ';
            }
            else if(box.BoxName == 'TAS')
            {
                acc.PLC_TAS__c = box.BoxLabel  + '-'+ box.CssClass +'; ';
            }
            else if(box.BoxName == 'Support')
            {
                acc.PLC_Support__c = box.BoxLabel  + '-'+ box.CssClass +'; ';
            }
            else if(box.BoxName == 'TW')
            {
                acc.PLC_TW__c = box.BoxLabel + '-'+ box.CssClass +'; ';
            }
            else if(box.BoxName == 'TFC')
            {
                acc.PLC_TFC__c = box.BoxLabel + '-'+ box.CssClass +'; ';
            }
              else if(box.BoxName == 'Spot Bidding')
            {
                acc.PLC_Spot_Bidding__c = box.BoxLabel + '-'+ box.CssClass +'; ';
            }
          }
          for(Product_Mapping__c item: prodMap.values())
          {
            if(item.Product_Family__c == 'CD')
            {
                if(this.ComputeColorForCD(item).CssClass == 'darkGreyBox')
                {
                    acc.PLC_CD__c += item.Product_Full_Name__c + '; ';
                }
            }
            else if(item.Product_Family__c == 'TW')
            {
                if(this.ComputeColorForTW(item).CssClass == 'darkGreyBox')
                {
                    acc.PLC_TW__c += item.Product_Full_Name__c + '; ';
                }
            }
            else if(item.Product_Family__c == 'FX' && item.Name != 'FX')
            {
                if(this.ComputeColorForFX(item).CssClass == 'darkGreyBox')
                {
                    acc.PLC_FX__c += item.Product_Full_Name__c + '; ';
                }
            }
            else if(item.Product_Family__c == 'TAS')
            {
                if(this.ComputeColorForTAS(item).CssClass == 'darkGreyBox')
                {
                    acc.PLC_TAS__c += item.Product_Full_Name__c + '; ';
                }
            }
            else if(item.Product_Family__c == 'Support')
            {
                if(this.ComputeColorForSupport(item).CssClass == 'darkGreyBox')
                {
                    acc.PLC_Support__c += item.Product_Full_Name__c + '; ';
                }
            }
            else if(item.Product_Family__c == 'TFC')
            {
                if(this.ComputeColorForTFC(item).CssClass == 'darkGreyBox')
                {
                    acc.PLC_TFC__c += item.Product_Full_Name__c + '; ';
                }
            }
            else if(item.Product_Family__c == 'Spot Bidding')
            {
                if(this.ComputeColorForSpot(item).CssClass == 'darkGreyBox')
                {
                    acc.PLC_Spot_Bidding__c += item.Product_Full_Name__c + '; ';
                }
            }
          }
          acc.PLC_TW__c += '/';
          acc.PLC_FX__c +='/';
          acc.PLC_TAS__c +='/';
          acc.PLC_Support__c +='/';
          acc.PLC_TFC__c +='/';
          acc.PLC_CD__c +='/';
          acc.PLC_Spot_Bidding__c +='/';
          List<ColorBox> lst = productFamilyBoxes.values();
          lst.sort();
          acc.ALC__c = lst.get(0).BoxLabel;
          update acc;
        }
    }
    
    private ColorBox parsePLCFieldForFamily(string field, string parentField, string productSummaryStatus)
    {
        ColorBox box = new ColorBox('Suspect',productSummaryStatus);
        ColorBox parentBox = new ColorBox('Suspect-Color3',productSummaryStatus);
        if(String.isNotEmpty(field))
        {
            box = new ColorBox(field.substring(field.indexOf('-')+1, field.indexOf(';')),productSummaryStatus);
        }
        if(String.isNotEmpty(parentField))
        {
        	List<string> parents = parentField.split('/',-1);
        	for(string p: parents)
        	{
                if(String.isNotEmpty(p))
                {
                    p.trim();
                    ColorBox preParent = new ColorBox(p.substring(p.indexOf('-')+1, p.indexOf(';')),productSummaryStatus);
                    parentBox.MergerBoxes(preParent);
                }
        	}
        }
        box.MergerBoxes(parentBox);
        return box;
    }
    
    private ColorBox parsePLCFieldForProduct(string field, string parentField, string value)
    {
        ColorBox box; 
        if(field.contains(value) || (parentField != null && parentField.contains(value)))
        {
            box = new ColorBox('darkGreyBox', value);
        }
        else
        {
            box = new ColorBox('lightGreyBox', value);
        }
        return box;
    }
    
    //The method to retrieve all needed data
    //Opportunity, Subscription for Account and Current Fees for Subscription
    private void getAllData()
    {
        List<Opportunity> opps = [
            Select 
                Id, Product_Interest__c, Offer_Template__r.Base_Product__r.Name,StageName, IsWon, IsClosed, CloseDate 
            From Opportunity 
            Where AccountId =: this.accId
        ];
        mapProductOppWithOffer = new Map<String,List<Opportunity>>();
        for(Opportunity opp: opps)
        {
            System.debug('------------------opp prod interest-------'+opp.Product_Interest__c);
            if(String.isNotEmpty(opp.Product_Interest__c)) 
            {
                if(opp.Product_Interest__c == 'TWD')
                {
                    opp.Product_Interest__c = 'TWA';
                }
                if(opp.Product_Interest__c == 'TFX')
                {
                    opp.Product_Interest__c = 'FX';
                }
                if(opp.Product_Interest__c == 'SB')
                {
                    opp.Product_Interest__c = 'Spot Bidding';
                }
                if(mapProductOppWithOffer.containsKey(opp.Product_Interest__c))
                {
                    mapProductOppWithOffer.get(opp.Product_Interest__c).add(opp);
                }
                else
                {
                    mapProductOppWithOffer.put(opp.Product_Interest__c, new List<Opportunity> {opp});
                } 
            }
            if(String.isNotEmpty(opp.Offer_Template__r.Base_Product__r.Name))
            {
                if(mapProductOppWithOffer.containsKey(opp.Offer_Template__r.Base_Product__r.Name))
                {
                    mapProductOppWithOffer.get(opp.Offer_Template__r.Base_Product__r.Name).add(opp);
                }
                else
                {
                    mapProductOppWithOffer.put(opp.Offer_Template__r.Base_Product__r.Name, new List<Opportunity> {opp});
                } 
            }
        }
        lstSubs.addAll([Select Status__c, Product__r.Name, Offer_Template__r.Name, Opportunity__r.ID, End_Date__c From Subscription__c Where Account__c =: this.accId]);
        System.Debug('----------subs--'+lstSubs);
        
        List<ID> lstSubId = new List<ID>();
        for(Subscription__c sub:lstSubs)
        {
            
            if(subBeforeUpdate!=null && sub.Id == subBeforeUpdate.Id)
            {
                sub.Status__c = subBeforeUpdate.Status__c;
            }
            if(sub.Product__r.Name == 'TAS English' || sub.Product__r.Name == 'TAS Offer')
            {
                sub.Product__r.Name = 'TAS';
            }
            lstSubId.add(sub.Id);
        }
        List<Subs_Current_Fee__c> lstSubPackAndFees = [select Subscription__r.ID,Start_Date__c, End_Date__c, Price__c, Name From Subs_Current_Fee__c Where Subscription__c =: lstSubId];
         System.Debug('----------fee--'+lstSubPackAndFees );
        for(integer i=0; i < lstSubPackAndFees.size(); i++)
        {
        	if(subExpiredCurName.containsKey(lstSubPackAndFees[i].Subscription__r.ID))
            {
                subExpiredCurName.get(lstSubPackAndFees[i].Subscription__r.ID).add(lstSubPackAndFees[i].Name);
            }
            else
            {
                subExpiredCurName.put(lstSubPackAndFees[i].Subscription__r.ID, new List<String> {lstSubPackAndFees[i].Name});
            }
            if(lstSubPackAndFees[i].End_Date__c == null)
            {
                lstSubPackAndFees[i].End_Date__c = Date.newInstance(2099, 2, 17);
            }
            if(lstSubPackAndFees[i].End_Date__c <= Date.today() || lstSubPackAndFees[i].Start_Date__c > Date.today())
            {
                lstSubPackAndFees.remove(i);
                i--;
            }
        }
        for(Subs_Current_Fee__c fee:lstSubPackAndFees)
        {
            if(fee.Price__c!= null)
            {
                if(subscriptionPrice.containsKey(fee.Subscription__r.ID))
                {
                    subscriptionPrice.put(fee.Subscription__r.ID, Double.valueOf(fee.Price__c) + subscriptionPrice.get(fee.Subscription__r.ID));
                }
                else
                {
                    subscriptionPrice.put(fee.Subscription__r.ID, Double.valueOf(fee.Price__c));
                }
            }
            if(subCurName.containsKey(fee.Subscription__r.ID))
            {
                subCurName.get(fee.Subscription__r.ID).add(fee.Name);
            }
            else
            {
                subCurName.put(fee.Subscription__r.ID, new List<String> {fee.Name});
            }
        }
    }
    
    private ColorBox ComputeColorForFX(Product_Mapping__c item) //done
    {
        for(Subscription__c sub: lstSubs)
        {           
            if(sub.Product__r.Name == item.Name && (sub.Status__c == 'Active' || (sub.Status__c == 'Cancelled'&& productFamilyBoxes.get('FX').ProdWeight < 10)))
            {
                return new ColorBox('darkGreyBox', item.Product_Full_Name__c);
            }
        }
        return new ColorBox('lightGreyBox', item.Product_Full_Name__c);
    }
    
    private ColorBox ComputeColorForTFC(Product_Mapping__c item)
    {
    	ColorBox result;
        for(Subscription__c sub: lstSubs)
        {            
            if(sub.Product__r.Name == item.Product_Family__c)
            {   
                if(result == null)
                {
            		result = ComputeColorHelper(sub.Id, sub.Status__c, item);
                }
                else
                {
                    result.MergeSmallBoxes(ComputeColorHelper(sub.Id, sub.Status__c, item));
                }
            }
        }
        return result == null ? new ColorBox('lightGreyBox', item.Product_Full_Name__c) : result;
    }
    
    private ColorBox ComputeColorForCD(Product_Mapping__c item) //done
    {
    	ColorBox result;
        for(Subscription__c sub: lstSubs)
        {
            if(result == null)
            {
                result = ComputeColorHelper(sub.Id, sub.Status__c, item);
            }
            else
            {
                result.MergeSmallBoxes(ComputeColorHelper(sub.Id, sub.Status__c, item));
            }
        }
        return result == null ? new ColorBox('lightGreyBox', item.Product_Full_Name__c) : result;
    }
    
    private ColorBox ComputeColorForTW(Product_Mapping__c item) //done
    {
    	ColorBox result;
        for(Subscription__c sub: lstSubs)
        {
            if(sub.Product__r.Name == 'TWA') 
            {
            	if(result == null)
                {
            		result = ComputeColorHelper(sub.Id, sub.Status__c, item);
                }
                else
                {
                    result.MergeSmallBoxes(ComputeColorHelper(sub.Id, sub.Status__c, item));
                }
            }
        }
        return result == null ? new ColorBox('lightGreyBox', item.Product_Full_Name__c) : result;
    } 
    private ColorBox ComputeColorForSpot(Product_Mapping__c item) //done
    {
    	ColorBox result;
        System.debug('------subs----' + lstSubs);
        for(Subscription__c sub: lstSubs)
        {
            if(sub.Product__r.Name == 'Spot Bidding' || sub.Product__r.Name == 'TFX') 
            {
                
            	if(result == null)
                {
            		result = ComputeColorHelper(sub.Id, sub.Status__c, item);
                    System.Debug('--I was in ComputeColorForSpot---' + result);
                }
                else
                {
                    result.MergeSmallBoxes(ComputeColorHelper(sub.Id, sub.Status__c, item));
                    System.Debug('--I was in ComputeColorForSpot---' + result);
                }
            }
        }
        return result == null ? new ColorBox('lightGreyBox', item.Product_Full_Name__c) : result;
    }
    
    private ColorBox ComputeColorForTAS(Product_Mapping__c item)
    {
        for(Subscription__c sub: lstSubs)
        {
            if(sub.Product__r.Name == 'TAS')
            {
            	if(subCurName.containsKey(sub.ID) && sub.Status__c == 'Active')
            	{
	                for(String feeName:subCurName.get(sub.ID))
	                {
	                    if((feeName == ptv1 || feeName == ptv2) && !this.isPTVAdded)
	                    {
	                        this.isPTVAdded = true;
	                        return new ColorBox('darkGreyBox', 'PTV');
	                    }
	                    if(feeName == item.Name)
	                    {
	                        return new ColorBox('darkGreyBox', item.Product_Full_Name__c);
	                    }
	                } 
            	}
            	if(subExpiredCurName.containsKey(sub.ID) && sub.Status__c == 'Cancelled')
            	{
            		for(String feeName:subExpiredCurName.get(sub.ID))
	                {
	                    if((feeName == ptv1 || feeName == ptv2) && !this.isPTVAdded)
	                    {
	                        this.isPTVAdded = true;
	                        return new ColorBox('darkGreyBox', 'PTV');
	                    }
	                    if(feeName == item.Name)
	                    {
	                        return new ColorBox('darkGreyBox', item.Product_Full_Name__c);
	                    }
	                } 
            	}
            }
        }
        return new ColorBox('lightGreyBox', item.Product_Full_Name__c);
    } 
    
    private ColorBox ComputeColorForSupport(Product_Mapping__c item)
    {
        for(Subscription__c sub:lstSubs)
        {
            if(sub.Offer_Template__r.Name == 'TW_Support'  && (sub.Status__c == 'Active' || sub.Status__c == 'Cancelled'))
            { 
                return new ColorBox('darkGreyBox', item.Product_Full_Name__c);
            }
        }
        return new ColorBox('lightGreyBox', item.Product_Full_Name__c);
    } 
    
    private ColorBox ComputeColorHelper(string subId, string status, Product_Mapping__c item)
    {
    	if(subCurName.containsKey(subId) && status == 'Active')
    	{
            for(String feeName:subCurName.get(subId))
            {
                if(feeName == item.Name)
                {
                     return new ColorBox('darkGreyBox', item.Product_Full_Name__c);
                }
            }
    	}
    	if(subExpiredCurName.containsKey(subId) && status == 'Cancelled')
    	{
    		for(String name:subExpiredCurName.get(subId))
            {
                if(item.Name == name)
                {
                    return new ColorBox('darkGreyBox', item.Product_Full_Name__c);
                }
            }
    	}
    	return null;
    }
    
    private ColorBox ComputeColorForProductCD(Product_Mapping__c item)
    {
        integer weight = 3;
        integer tempWeight = 3;
        for(Subscription__c sub:lstSubs)
        {
            if(sub.Product__r.Name == 'T-PRO'||sub.Product__r.Name == 'T-ACTIVE')
            {
                tempWeight = HelperForCalculateCDWeight(sub);
                weight = weight > tempWeight ? weight : tempWeight;
            }
            if(subCurName.containsKey(sub.ID))
            {
                for(String feeName:subCurName.get(sub.ID))
                {
                    if(feeName == item.Name)
                    {
                        tempWeight = HelperForCalculateCDWeight(sub);
                		weight = weight > tempWeight ? weight : tempWeight;
                    }
                }
            }
        }
        return new ColorBox(item.Product_Family__c, weight);
    }
    
    private integer HelperForCalculateCDWeight(Subscription__c sub)
    {
        Integer weight = 3;
        if(sub.Status__c == 'Active')
        {
            if(subscriptionPrice.get(sub.ID) > 0)
            {
                weight = 11;
            }
            else if(subscriptionPrice.get(sub.ID) == 0)
            {
                weight = weight > 10 ? weight : 10;
            }
        }
        if(sub.Status__c == 'Cancelled')
        {
            weight = weight > 8 ? weight : 8;
        }
        return weight;
    }
    private ColorBox ComputeColorForProductFamily(Product_Mapping__c item)
    {
        String itemName = item.Name;
        if(item.Product_Family__c == 'TW')
        {
            itemName = 'TWA';
        }
        if(item.Product_Family__c == 'TAS')
        {
            itemname = 'TAS';
        }
        if(item.Product_Family__c == 'TFC')
        {
            itemname = 'TFC';
        }
        if(item.Product_Family__c == 'Spot Bidding')
        {
            itemname = 'Spot Bidding';
        }
        List<Opportunity> lstOpps = new List<Opportunity>();
        Integer weight = 0;
        if(mapProductOppWithOffer.containsKey(itemName))
        {
            lstOpps= mapProductOppWithOffer.get(itemName);
        } 
        if(lstOpps.size() == 0)
        {
            weight = weight > 3 ? weight : 3;
        }
        for(Subscription__c sub:lstSubs)
        {
            if(sub.Product__r.Name == itemName)
            {
                if((sub.Status__c == 'Active' || sub.Status__c == 'Migration') && subscriptionPrice.containsKey(sub.ID))
                {
                    if(subscriptionPrice.get(sub.ID) > 0)
                    {
                        weight = 11;
                    }
                    else if(subscriptionPrice.get(sub.ID) == 0)
                    {
                        weight = weight > 10 ? weight : 10;
                    }   
                }
                if(sub.Status__c == 'Trial' && sub.End_Date__c >= Date.today())
                {
                    weight = weight > 9 ? weight : 9;
                    System.Debug('-------------9----'+weight );
                }
                if(sub.Status__c == 'Cancelled')
                {
                    weight = weight > 8 ? weight : 8;
                }
                if(sub.Status__c == 'On Notice')
                {
                    weight = weight > 7 ? weight : 7;
                }
                if(sub.Status__c == 'Trial' && sub.End_Date__c < Date.today())
                {
                    weight = weight > 6 ? weight : 6;
                }
                if(sub.Status__c == 'Cancelled Trial')
                {
                    weight = weight > 5 ? weight : 5;
                }
                if(sub.Status__c == 'Provisioning initiated'
                ||sub.Status__c == 'Waiting For Provisioning' || sub.Status__c == 'Waiting For Payment')
                {
                    weight = weight > 4 ? weight : 4;
                }
            }
        }
        for(Opportunity opp:lstOpps)
        {
            if(opp.StageName == '12 Closed Frozen')
            {
                weight = weight > 2 ? weight : 2;
            }
            if(!opp.isClosed||(opp.isClosed&&opp.isWon))
            {
                weight = weight > 4 ? weight : 4;
            }
            if(opp.isClosed&&!opp.isWon)
            {
                weight = weight > 3 ? weight : 3;
            }
        }  
        weight = weight > 1 ? weight : 1;
        return new  ColorBox( item.Product_Family__c, weight);
    }
}