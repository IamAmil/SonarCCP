import { LightningElement,track,wire } from 'lwc';
import backgroundImage from '@salesforce/resourceUrl/CCP2_Resources';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord} from 'lightning/uiRecordApi';
// import truckcancel from '@salesforce/resourceUrl/truckcancel1';
// import truckcancel2 from '@salesforce/resourceUrl/truckcancel2';
// import truckcancel3 from '@salesforce/resourceUrl/truckcancel3';
import userData from '@salesforce/apex/CCP2_userData.userDtl';
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
import USER_ACCOUNT_ID_FIELD from '@salesforce/schema/User.AccountId';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/Account.Type';
import deleteadmin from '@salesforce/apex/CCP2_UserDeleteController.optoutDeleteUser';
import updatecontactdelete from '@salesforce/apex/CCP2_userController.updateContactFields';
import checkManagerUser from "@salesforce/apex/CCP_HeaderController.checkManagerUser";
import CCP2_Withdraw from '@salesforce/label/c.CCP2_Withdraw';
import CCP2_DiscontinueMembership from '@salesforce/label/c.CCP2_DiscontinueMembership';
import CCP2_No from '@salesforce/label/c.CCP2_No';
import CCP2_Yes from '@salesforce/label/c.CCP2_Yes';
import CCP2_CancelMembership from '@salesforce/label/c.CCP2_CancelMembership';
import CCP2_ServicesList from '@salesforce/label/c.CCP2_ServicesList';
import CCP2_MonthlyRequestForm from '@salesforce/label/c.CCP2_MonthlyRequestForm';
import CCP2_FinancialServices from '@salesforce/label/c.CCP2_FinancialServices';
import CCP2_ReservationForVehicleInspection from '@salesforce/label/c.CCP2_ReservationForVehicleInspection';
import CCP2_VehicleManagement from '@salesforce/label/c.CCP2_VehicleManagement';
import CCP2_ExpenseManagement from '@salesforce/label/c.CCP2_ExpenseManagement';
import CCP2_ApplicationDiscontinuation from '@salesforce/label/c.CCP2_ApplicationDiscontinuation';
import CCP2_CompanyName from '@salesforce/label/c.CCP2_CompanyName';
import CCP2_CustomerId from '@salesforce/label/c.CCP2_CustomerId';
import CCP2_FullName from '@salesforce/label/c.CCP2_FullName';
import CCP2_NameFurigana from '@salesforce/label/c.CCP2_NameFurigana';
import CCP2_EmployeeNumber from '@salesforce/label/c.CCP2_EmployeeNumber';
import CCP2_WorkLocation from '@salesforce/label/c.CCP2_WorkLocation';
import CCP2_Department from '@salesforce/label/c.CCP2_Department';
import CCP2_Position from '@salesforce/label/c.CCP2_Position';
import CCP2_EmailAddress from '@salesforce/label/c.CCP2_EmailAddress';
import CCP2_TelephoneNo from '@salesforce/label/c.CCP2_TelephoneNo';
import CCP2_MobileNo from '@salesforce/label/c.CCP2_MobileNo';
import CCP2_CancellationRequest from '@salesforce/label/c.CCP2_CancellationRequest';
import CCP2_ReasonForDiscontinuation from '@salesforce/label/c.CCP2_ReasonForDiscontinuation';
import CCP2_LowFrequency from '@salesforce/label/c.CCP2_LowFrequency';
import CCP2_Required from "@salesforce/label/c.CCP2_Required";
import CCP2_PoorUsability from '@salesforce/label/c.CCP2_PoorUsability';
import CCP2_DataAccuracyDissatisfaction from '@salesforce/label/c.CCP2_DataAccuracyDissatisfaction';
import CCP2_FewMemberBenefits from '@salesforce/label/c.CCP2_FewMemberBenefits';
import CCP2_FoundBetterProduct from '@salesforce/label/c.CCP2_FoundBetterProduct';
import CCP2_BusinessClosure from '@salesforce/label/c.CCP2_BusinessClosure';
import CCP2_Other from '@salesforce/label/c.CCP2_Other';
import CCP2_DeleteData from '@salesforce/label/c.CCP2_DeleteData';
import CCP2_DataDeletionNote from '@salesforce/label/c.CCP2_DataDeletionNote';
import CCP2_Next from '@salesforce/label/c.CCP2_Next';
import CCP2_Previous from '@salesforce/label/c.CCP2_Previous';
import CCP2_TOPPage from '@salesforce/label/c.CCP2_TOPPage';
import branchdetails from '@salesforce/apex/CCP2_userData.userBranchDtl';

const BACKGROUND_IMAGE_PC = backgroundImage + '/CCP2_Resources/Common/Main_Background.webp';

const truckcancel = backgroundImage + '/CCP2_Resources/Cancelmembership/truckcancel1.png';
const truckcancel2 = backgroundImage + '/CCP2_Resources/Cancelmembership/truckcancel2.png';
const truckcancel3 = backgroundImage + '/CCP2_Resources/Cancelmembership/truckcancel3.png';

export default class Ccp2CancelMembership extends LightningElement {
    @track showWithdraw = false;
    labels = {
        CCP2_Withdraw,
        CCP2_DiscontinueMembership,
        CCP2_No,
        CCP2_Required,
        CCP2_Yes,
        CCP2_CancelMembership,
        CCP2_ServicesList,
        CCP2_MonthlyRequestForm,
        CCP2_FinancialServices,
        CCP2_ReservationForVehicleInspection,
        CCP2_VehicleManagement,
        CCP2_ExpenseManagement,
        CCP2_ApplicationDiscontinuation,
        CCP2_CompanyName,
        CCP2_CustomerId,
        CCP2_FullName,
        CCP2_NameFurigana,
        CCP2_EmployeeNumber,
        CCP2_WorkLocation,
        CCP2_Department,
        CCP2_Position,
        CCP2_EmailAddress,
        CCP2_TelephoneNo,
        CCP2_MobileNo,
        CCP2_CancellationRequest,
        CCP2_ReasonForDiscontinuation,
        CCP2_LowFrequency,
        CCP2_PoorUsability,
        CCP2_DataAccuracyDissatisfaction,
        CCP2_FewMemberBenefits,
        CCP2_FoundBetterProduct,
        CCP2_BusinessClosure,
        CCP2_Other,
        CCP2_DeleteData,
        CCP2_DataDeletionNote,
        CCP2_Next,
        CCP2_Previous,
        CCP2_TOPPage
    };

    truckpic1 = truckcancel;
    truckpic2 = truckcancel2;
    truckpic3 = truckcancel3;
    backgroundImagePC = BACKGROUND_IMAGE_PC;
    @track showCancelModal = false;

    @track branchfromjunction = [];
    @track hidebasicInfo = false;
    @track showConformpage = false;
    @track showconfModal = false;
    @track showstep1 = true;
    @track showstep2 = false;
    @track selectedReasonMessage = '';
    @track showstep3 = false;
    @track showServiceModal = false;
    @track isInputDisabled = true;
    @track UserDetails = []; 

    @track CompanyName = '';
    @track selectedReasons = []; // Array to store selected reasons
    @track selectedReason = '';  // Initialize with the pre-selected value
    @track otherReason = '';
    @track showOtherInput = false;
    @track deletecheckbox = '「未選択（6ヶ月内に再入会しない場合、アカウントとデータを永久に削除します。）」';
    @track accountId;
    @track userDetailData = {
        Name: null,
        id: null,
        email: null,
        account: {
          id: null,
          name: null,
          siebelAccountCode__c: null,
          Industry: null
        },
        Branch__r: {
          name: null
        },
        MobilePhone: null,
        Department: null,
        Employee_Code__c: null,
        Phone:null,
        firstNameKana__c:null,
        lastNameKana__c:null,
        Title:null
      };


      allReasons = [
        "使用頻度が低い",
        "操作性が悪い",
        "データ精度に不満がある",
        "会員向けの特典・サービスが少ない",
        "他によい商品を見つけた",
        "廃業の為",
        "その他"
    ];
    userId = USER_ID;
    @track contactId;
    @track accountName;

    
    renderedCallback() {
        // Restore checkbox states based on selectedReasons
        this.template.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
            if (checkbox.name === 'reason') {
                checkbox.checked = this.selectedReasons.includes(checkbox.value);
            } else if (checkbox.name === 'deletedata') {
                checkbox.checked = (checkbox.value === this.deletecheckbox);
            }
        });
    }
    connectedCallback(){
        this.checkManagerUser();
        const link = document.createElement('link');
        link.href = 'https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@100..900&display=swap';
        link.rel = 'stylesheet';
        document.head.appendChild(link);

        let baseUrl = window.location.href;
        this.basicInfo = baseUrl.split("/s/")[0] + "/s/profile";
    }
    onclose(){
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }

    checkManagerUser() {
        checkManagerUser()
          .then((result) => {
            console.log("checkManagerUser result: ", result);
           this.showWithdraw = result;
          })
          .catch((error) => {
            this.errors = JSON.stringify(error);
            console.log("checkManagerUser errors:" + JSON.stringify(error));
          });
      }

    deleteadmin() {
        deleteadmin({ contactId: this.contactId })
          .then((result) => {
             })
          .catch((error) => {
            console.log("delete User Fetching error id :" + this.contactId);
            console.error("delete User Fetching error:" + JSON.stringify(error));
          });
      }
    

    @wire(branchdetails, {User: "$contactId"})
    wiredbranches2({data,error}){
    if(data){
        if (data.length > 0) {
            this.branchfromjunction = data.map(branch => ({ Name: branch.Name }));
        } else {
      this.branchfromjunction = [{Name: "-"}]
        }
    }else{
        
      console.log("error in fetching branches from new",error);
    }
  }
    @wire(userData,{User:'$contactId',refresh: 1})
    fetchUserData({data,error}){
        if(data){
            this.userDetailData = {
                Name: data[0].Name == null ? '-' : data[0].Name,
                id: data[0].Id == null ? '-' : data[0].Id,
                email: data[0].Email == null ? "-" : data[0].Email,
                account: {
                    id: data[0].Account.Id == null ? '-' : data[0].Account.Id,
                    name: data[0].Account.Name == null ? '-' : data[0].Account.Name,
                    SiebelAccountCode__c: data[0].Account.siebelAccountCode__c == null ? '-' : data[0].Account.siebelAccountCode__c,
                },
                Branchs: data[0].Branchs__r == undefined ? [{Name:'-'}] : data[0].Branchs__r,
                MobilePhone: data[0].MobilePhone == null ? '-' : data[0].MobilePhone,
                Department: data[0].Department == null ? '-' : data[0].Department,
                Employee_Code__c: data[0].Employee_Code__c == null ? '-' : data[0].Employee_Code__c,
                Phone: data[0].Phone == null ? '-' : data[0].Phone,
                firstNameKana__c: data[0].firstNameKana__c == null ? '-' : data[0].firstNameKana__c,
                lastNameKana__c: data[0].lastNameKana__c == null ? '-' : data[0].lastNameKana__c,
                Title: data[0].Title == null ? '-' : data[0].Title
            }

    } else if(error){
        console.log("error,",error);
    }
    }


    @wire(getRecord, {
        recordId: '$userId',
        fields: [CONTACT_ID_FIELD, USER_ACCOUNT_ID_FIELD]
    })
    userRecord({ error, data }) {
        if (data) {
            this.contactId = data.fields.ContactId.value;
            this.accountId = data.fields.AccountId.value;
            console.log('Contact ID:', this.contactId);
        } else if (error) {
            console.error('Error fetching user record:', error);
        }
    }

    @wire(getRecord, {
        recordId: '$accountId',
        fields: [ACCOUNT_NAME_FIELD, ACCOUNT_TYPE_FIELD]
    })
    accountDetailHandler({ error, data }) {
        if (data) {
            this.accountName = data.fields.Name.value;
        } else if (error) {
            console.error(error);
        }
    }
   
    
    handlewithdraw(){
        this.showconfModal = false;
        this.showServiceModal = true;
        this.showConformpage = false;
        this.hidebasicInfo = true;
    }



    handleYesmodal2(){
        window.scrollTo(0,0);
        const events = new CustomEvent("closem")
        this.dispatchEvent(events);
        this.showServiceModal = false;
        this.showWithdraw = false;
        this.showConformpage = true;
        this.showstep1 = true;
    }

    handleNomodal2(){
        this.showServiceModal=false;
        this.hidebasicInfo = true;
    }

    handleTop(){
        this.hidebasicInfo = true;
        this.showstep3 = false;
        this.showstep1 = false;
        this.showstep2 = false;
        this.showConformpage = false;
    }

    handleNo() {
        // Handle No action
        this.showconfModal = false;
        this.showstep2 = true;
        
    }

    handlestep1() {
        window.scrollTo(0, 0);
    
        // Check if any reason is selected
        if (this.selectedReasons.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "エラー",
                    message: "退会理由を選択してください。",
                    variant: "error"
                })
            );
            return;
        }
    
        // Check if 'その他' reason is selected and otherReason is empty
        if (this.selectedReasons.includes('その他') && this.otherReason.trim() === '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "エラー",
                    message: "コメント欄に理由を述べてください。",
                    variant: "error"
                })
            );
            return;
        }
    
        // Proceed to step 2 and prepare selected reasons messages
        this.showstep1 = false;
        this.showstep2 = true;
    
        // Prepare array of selected reason messages
        this.selectedReasonMessages = this.selectedReasons.map(reason => {
            if (reason === 'その他') {
                return this.otherReason; // Display 'other' reason if selected
            }
            return reason;
        });
    }
    

    handlestep2(){
        this.showstep1 = false;
        this.showstep2 = true;
        // this.showconfModal = true;
        this.showServiceModal = false;
        // this.showstep3 = true;
        window.scrollTo(0,0);
        this.showstep2 = false;
        // this.showconfModal = false;
        this.showstep3 = true;
        this.deleteadmin(this.contactId);
        updatecontactdelete({selectedReason: this.selectedReasons,contactId: this.contactId,other: this.otherReason})
        .then((result) => {
            // this.handleDeleteSuccess();
            //console.log("delete user api data response : ", this.contactId);
            console.log("result in update",result);
            console.log("inside")
          })
          .catch((error) => {
            console.log("update User Fetching error id :" + this.contactId);
            console.error("update User Fetching error:" + JSON.stringify(error));
          });
    }

    handlePrevstep2(){
        window.scrollTo(0,0);
        this.showstep1 = true;
        console.log("selected reasons",JSON.stringify(this.selectedReasons));        // this.selectedReason = '';
       
        this.showstep2 = false;
        this.deletecheckbox = '「未選択（6ヶ月内に再入会しない場合、アカウントとデータを永久に削除します。）」';
        console.log("selected reason on prev",this.selectedReason);
    }

    
    handleReasonChange(event) {
      let selectedValue = event.target.value;
        if (event.target.checked) {
            // Add selected reason to array while maintaining order
            if (!this.selectedReasons.includes(selectedValue)) {
                this.selectedReasons = [...this.selectedReasons, selectedValue];
            }
        } else {
            // Remove deselected reason from array
            this.selectedReasons = this.selectedReasons.filter(reason => reason !== selectedValue);
        }
        this.isInputDisabled = !this.selectedReasons.includes('その他');
        console.log("Selected reasons:", JSON.stringify(this.selectedReasons));
    }


    get selectedReasonMessages() {
        return this.allReasons
            .filter(reason => this.selectedReasons.includes(reason))
            .map(reason => {
                if (reason === 'その他') {
                    return this.otherReason; // Display 'other' reason if selected
                }
                return reason;
            });
    }

    handleOtherReasonChange(event) {
        this.otherReason = event.target.value;
        console.log("other reason",this.otherReason);
    }

    handleCheckbox(event){
        if (event.target.checked) {
            this.deletecheckbox = event.target.value;
        } else {
            this.deletecheckbox = '「未選択（6ヶ月内に再入会しない場合、アカウントとデータを永久に削除します。）」';
        }
    }
    get getRadioClasscheck(){
        return this.deletecheckbox ? 'selected2' : '';
    }
    

    navigateToHome() {
        let baseUrl = window.location.href;
        let homeUrl;
        if(baseUrl.indexOf("/s/") != -1) {
            homeUrl = baseUrl.split("/s/")[0] + '/s/';
        }
        window.location.href = homeUrl;
    }
    handleCancel(){
        this.showCancelModal = true;
    }
    handleCancelNo(){
        this.showCancelModal = false;
        // this.showConformpage = true;
    }
    handleCancelYes(){
        // this.reloadPage();
        window.scrollTo(0,0);
        this.open();
        this.selectedReasons = [];
        this.otherReason = '';
        this.deletecheckbox = '「未選択（6ヶ月内に再入会しない場合、アカウントとデータを永久に削除します。）」'
        this.showCancelModal = false;
        this.showWithdraw = true;
        this.showConformpage = false;
        // this.showWithdraw = true;
    }
    reloadPage() {
        location.reload();
      }
      open() {
    
        const openEvent = new CustomEvent('openbasic', {
            bubbles: true,
            composed: true
        });
        console.log('Dispatching openmember event');
        this.dispatchEvent(openEvent);
      }
}