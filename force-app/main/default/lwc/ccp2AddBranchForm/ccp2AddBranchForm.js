import { LightningElement, track, wire } from 'lwc';
import Vehicle_StaticResource from '@salesforce/resourceUrl/CCP_StaticResource_Vehicle';
import getVehicleWithoutAssociation from '@salesforce/apex/CCP2_userData.VehicleWithoutAssociation';
import getUsersWithoutAssociation from '@salesforce/apex/CCP2_userData.userList';
import AddBranch from '@salesforce/apex/CCP2_branchManagement.createAndAssociateBranch';
import getAccount from '@salesforce/apex/CCP2_userData.accountDetails';
import Img1 from '@salesforce/resourceUrl/ccp2HeaderImg1';
import Img2 from '@salesforce/resourceUrl/ccp2HeaderImg2';
import Img3 from '@salesforce/resourceUrl/ccp2HeaderImg3';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import ACCOUNT_ID_FIELD  from '@salesforce/schema/User.AccountId';
const  arrowicon = Vehicle_StaticResource + '/CCP_StaticResource_Vehicle/images/arrow_under.png';

import CCP2_PleaseEnterBasicInfo from '@salesforce/label/c.CCP2_PleaseEnterBasicInfo';
import CCP2_OnlyOneBranchCanBeAdded from '@salesforce/label/c.CCP2_OnlyOneBranchCanBeAdded';
import CCP2_CompanyName from '@salesforce/label/c.CCP2_CompanyName';
import CCP2_BranchName from '@salesforce/label/c.CCP2_BranchName';
import CCP2_Required from '@salesforce/label/c.CCP2_Required';
import CCP2_Address from '@salesforce/label/c.CCP2_Address';
import CCP2_AffiliatedVehicles from '@salesforce/label/c.CCP2_AffiliatedVehicles';
import CCP2_SelectVehicles from '@salesforce/label/c.CCP2_SelectVehicles';
import CCP2_AffiliatedUsers from '@salesforce/label/c.CCP2_AffiliatedUsers';
import CCP2_ContactDetails from '@salesforce/label/c.CCP2_ContactDetails';
import CCP2_PleaseEnterPhoneNumber from '@salesforce/label/c.CCP2_PleaseEnterPhoneNumber';
import CCP2_TelephoneNumber from '@salesforce/label/c.CCP2_TelephoneNumber';
import CCP2_MobileNumber from '@salesforce/label/c.CCP2_MobileNumber';
import CCP2_AgreeToTerms from '@salesforce/label/c.CCP2_AgreeToTerms';
import CCP2_AgreeToDataProtection from '@salesforce/label/c.CCP2_AgreeToDataProtection';
import CCP2_Next from '@salesforce/label/c.CCP2_Next';
import CCP2_ConfirmDetails from '@salesforce/label/c.CCP2_ConfirmDetails';
import CCP2_Modify from '@salesforce/label/c.CCP2_Modify';
import CCP2_BackToBranchManagement from '@salesforce/label/c.CCP2_BackToBranchManagement';
import CCP2_WIthoutHyphen from '@salesforce/label/c.CCP2_WIthoutHyphen';
import CCP2_AddWorkLocation from '@salesforce/label/c.CCP2_AddWorkLocation';
import CCP2_AddBranch from '@salesforce/label/c.CCP2_AddBranch';
import CCP2_BranchAddCompleted from '@salesforce/label/c.CCP2_BranchAddCompleted';
import CCP2_AssignVehicleRelevant from '@salesforce/label/c.CCP2_AssignVehicleRelevant';
import CCP2_AssignMemberRelevant from '@salesforce/label/c.CCP2_AssignMemberRelevant';
import CCP2_PleaseSelect from '@salesforce/label/c.CCP2_PleaseSelect';
import CCP2_PleaseEnter from '@salesforce/label/c.CCP2_PleaseEnter';
import CCP2_BranchAdded from '@salesforce/label/c.CCP2_BranchAdded';
import CCP2_SelectedVehicle from '@salesforce/label/c.CCP2_SelectedVehicle';
import CCP2_SelectedMembers from '@salesforce/label/c.CCP2_SelectedMembers';
 


const BACKGROUND_IMAGE_PC = Vehicle_StaticResource + '/CCP_StaticResource_Vehicle/images/Main_Background.png';

export default class Ccp2AddBranchForm extends LightningElement {
    labels = {
        CCP2_PleaseEnterBasicInfo: CCP2_PleaseEnterBasicInfo,
        CCP2_OnlyOneBranchCanBeAdded: CCP2_OnlyOneBranchCanBeAdded,
        CCP2_CompanyName: CCP2_CompanyName,
        CCP2_BranchName: CCP2_BranchName,
        CCP2_Required: CCP2_Required,
        CCP2_Address: CCP2_Address,
        CCP2_AffiliatedVehicles: CCP2_AffiliatedVehicles,
        CCP2_SelectVehicles: CCP2_SelectVehicles,
        CCP2_AffiliatedUsers: CCP2_AffiliatedUsers,
        CCP2_ContactDetails: CCP2_ContactDetails,
        CCP2_PleaseEnterPhoneNumber: CCP2_PleaseEnterPhoneNumber,
        CCP2_TelephoneNumber: CCP2_TelephoneNumber,
        CCP2_MobileNumber: CCP2_MobileNumber,
        CCP2_AgreeToTerms: CCP2_AgreeToTerms,
        CCP2_AgreeToDataProtection: CCP2_AgreeToDataProtection,
        CCP2_Next: CCP2_Next,
        CCP2_ConfirmDetails: CCP2_ConfirmDetails,
        CCP2_Modify: CCP2_Modify,
        CCP2_BackToBranchManagement: CCP2_BackToBranchManagement,
        CCP2_WIthoutHyphen: CCP2_WIthoutHyphen,
        CCP2_AddWorkLocation: CCP2_AddWorkLocation,
        CCP2_AddBranch: CCP2_AddBranch,
        CCP2_BranchAddCompleted: CCP2_BranchAddCompleted,
        CCP2_AssignVehicleRelevant: CCP2_AssignVehicleRelevant,
        CCP2_AssignMemberRelevant:CCP2_AssignMemberRelevant,
        CCP2_PleaseSelect: CCP2_PleaseSelect,
        CCP2_PleaseEnter: CCP2_PleaseEnter,
        CCP2_BranchAdded: CCP2_BranchAdded,
        CCP2_SelectedVehicle: CCP2_SelectedVehicle,
        CCP2_SelectedMembers: CCP2_SelectedMembers

    };

    imgdrop = arrowicon;
    backgroundImagePC = BACKGROUND_IMAGE_PC;
    Image1 = Img1;
    Image2 = Img2;
    Image3 = Img3;
    @track Step1 = true;
    @track Step2 = false;
    @track Step3 = false;
    @track currentStep = 1; 
    @track callMain = false;
    @track addbranchpage = true;
    @track showList = false;
    @track showListUser = false;
    @track companyName = ''; 
    // @track branchId = '';
    @track branchName = '';
    @track selectedVehicle = '';
    @track selectedUser = '';
    @track address = '';
    @track phone = '';
    @track fax = '';
    @track termsService = false;
    @track termsAgree = false;
    @track deletedVehicleIds = [];
    @track vehicles = []; 
    @track morevehicles = [];
    @track selectedVehicleId; // Selected vehicle Id
    @track users = []; // Array to hold users for combobox
    @track moreusers = [];// Selected user Id
    @track selectedUser = ''; // Selected user (will hold the name)
    @track selectedUserId;

    @track isNextDisabled = true;
    searchTerm = '';
    outsideClickHandlerAdded = false;

  
    
    connectedCallback() {
       
 this.template.host.style.setProperty('--dropdown-icon', `url(${this.imgdrop})`);
        this.loadVehicles();
        this.loadUsers();

    }
    userId = USER_ID;
    accountId;

    @wire(getRecord, {
        recordId: '$userId',
        fields: [ACCOUNT_ID_FIELD]
    })
    userRecord({ error, data }) {
        if (data) {
            this.accountId = getFieldValue(data, ACCOUNT_ID_FIELD);
        } else if (error) {
            console.error('Error fetching user record:', error);
        }
    }
    @track AccountName;

    @wire(getAccount)loadaccount({data,error}){
        if(data){
            console.log("mydata",data);
            this.AccountName = data[0].Name;
        }else if(error){
            console.log(error);
        }
    }

   @wire(getVehicleWithoutAssociation)
    loadVehicles(data,error) {

        getVehicleWithoutAssociation()
            .then(result => {
                this.vehicles = result.map(vehicle => ({
                    label: vehicle.Name,
                    value: vehicle.Id
                }));

            })
            .catch(error => {
                console.error('Error fetching vehicles:', error);
            });
    }
    loadUsers() {
        getUsersWithoutAssociation()
            .then(result => {
                this.users = result.map(user => ({
                    label: user.Name,
                    value: user.Id
                }));
                console.log(JSON)
            })
            .catch(error => {
                console.error('Error fetching users:', error);
            });
    }
    openlist(event){
        event.stopPropagation();
        this.showList = !this.showList;
        if(this.vehicles.length === 0){
            this.showList = false;
          }

    }
    openlistUser(event){
        event.stopPropagation();
        this.showListUser = !this.showListUser;
        if(this.users.length === 0){
            this.showListUser = false;
        }
    }

    handleVehicleChange() {
        
        let selectedVehicle = '';
        for (let i = 0; i < this.vehicles.length; i++) {
            if (this.vehicles[i].value === this.selectedVehicleId) {
                selectedVehicle = this.vehicles[i];
                this.vehicles = this.vehicles.filter(veh => veh.value !== this.selectedVehicleId);
                break;
            }
        }

        if (selectedVehicle) {
            this.morevehicles.push({ Id: selectedVehicle.value, Name: selectedVehicle.label });
            }
            this.selectedVehicleId = null;
            if(this.vehicles.length === 0){
                this.showList = false;
              }

       
    }

    handleUserChange() {
        
        let selectedUser = '';
        for (let i = 0; i < this.users.length; i++) {
            if (this.users[i].value === this.selectedUserId) {
                selectedUser = this.users[i];
                this.users = this.users.filter(memb => memb.value !== this.selectedUserId);
                
                break;
            }
        }

        if (selectedUser) {
            this.moreusers.push({ Id: selectedUser.value, Name: selectedUser.label });
        }

        this.selectedUserId = null;

        if(this.users.length === 0){
            this.showListUser = false;
        }
       
    }
  

    handleSelectionChange(event) {
        const vehicleId = event.target.value;
        const isSelected = event.target.checked;
 
        this.vehicles = this.vehicles.map(vehicle => {
            if (vehicle.value === vehicleId) {
                return { ...vehicle, selected: isSelected };
            }
            return vehicle;
        });
 
        this.updateSelectedLabels();
    }

    updateSelectedLabels() {
        this.selectedLabels = this.vehicles
            .filter(vehicle => vehicle.selected)
            .map(vehicle => vehicle.label)
            .join(', ');
    }
 
    saveSelections() {
        this.updateSelectedLabels();
        this.toggleDropdown();
    }


    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    
  
    // handleNext() {
    //     try {
    //         let isValid = true;
    
    //         if (this.currentStep === 1) {
    //             if (!this.branchName || !this.phone  ) {
    //                 isValid = false;
    //                 if (!this.branchName) {
    //                     throw new Error('Please fill in Branch Name.');
    //                 }
                    
    //                 if (!this.validatePhone(this.phone)) {
    //                     throw new Error('Please enter a valid 10-digit phone number.');
    //                 }  
    //             }
             
    //         }
    
    //         if (isValid) {
    //             this.Step1 = false;
    //             this.Step2 = true;
    //             this.currentStep = 2;
    //         }
    //     } catch (error) {
    //         this.showToast('Error', error.message, 'error');
    //     }
    // }
    handleNext() {
        try {
            let isValid = true;
            
            if (this.currentStep === 1) {
                if (!this.branchName) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            //title: 'Error',
                            message: '勤務地名を入力してください',
                            variant: 'error',
                        })
                    );
                    //Please fill in branch name.
                    // this.showToast('Error', '勤務地名を入力してください', 'error');
                    return false; // Validation failed
                }
    
                if (this.phone !== '' && !this.validatePhone(this.phone)) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            //title: 'Error',
                            message: '有効な 10 桁の電話番号を入力してください.',
                            variant: 'error',
                        })
                    );
                    // this.showToast('Error', 'Please enter a valid 10-digit phone number.', 'error');
                    return false; // Validation failed
                }

            }
    
            if (isValid) {
                this.Step1 = false;
                this.Step2 = true;
                this.currentStep = 2;
            }
        } catch (error) {
            this.showToast('Error', error.message, 'error');
        }
    }   
    

    validateBranchName() {
        if (!this.branchName) {
            this.template.querySelector('.product-name').classList.add('error');
        } else {
            this.template.querySelector('.product-name').classList.remove('error');
        }
    }

    handlePrevious() {
        if (this.currentStep === 2) {
            // Move back to Step 1
            this.Step1 = true;
            this.Step2 = false;
            this.currentStep = 1;
        } else if (this.currentStep === 3) {
            // Move back to Step 2
            this.Step2 = true;
            this.Step3 = false;
            this.currentStep = 2;
        }
    }

    handleInput(event){
        const input = event.target;
        input.value = input.value.replace(/\D/g, '').slice(0, 10); 
        this.validatePhone(input.value);
    }
 


    handle2Next() {
        this.Step2 = false;
        this.Step3 = true;
        this.currentStep = 3;
        let vehicleIds = this.morevehicles.map(vehicle => vehicle.Id);
        console.log("map",JSON.stringify(vehicleIds));
        console.log("veh",JSON.stringify(this.morevehicles));

        let contactIds = this.moreusers.map(user => user.Id);

     let params = {
        vehicleIds: vehicleIds,
        contactIds: contactIds,
        accId: this.accountId,
        address: this.address,
        branchName: this.branchName,
        telephoneNo: this.phone,
        cellPhoneNo: this.fax,
        companyName: this.AccountName,
        // branchNumber: '0003'
    };
    console.log(JSON.stringify(params));

    AddBranch(params)
        .then(result => {
            console.log('Record inserted successfully:', result);
            this.dispatchEvent(
                new ShowToastEvent({
                    //title: 'Success',
                    message: '新規勤務地が追加されました。',
                    variant: 'success',
                })
            );
            // this.showToast('Success', '新規勤務地が追加されました。', 'success');
        })
        .catch(error => {
            console.error('Error inserting branch record:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    //title: 'error',
                    message: 'ブランチレコードの挿入中にエラーが発生しました。もう一度試してください。',
                    variant: 'error',
                })
            );
            // this.showToast('Error', 'Error inserting branch record. Please try again.', 'error');
        });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    
    }


    handleCompanyNameChange(event) {
        console.log(this.companyName);
        this.companyName = event.target.value;
    }

    // handleBranchIdChange(event) {
    //     this.branchId = event.target.value;
    // }

    addressChange(event){
        this.address = event.target.value;

    }

    handleBranchNameChange(event) {
        this.branchName = event.target.value;
        this.validateBranchName();
    }

    // handlePhoneChange(event) {
    //     this.phone = event.target.value;
    //            this.validatePhone();han
        
    // }
    handlePhoneChange(event) {
        const input = event.target;
        console.log("212wsw",input);
        const cleanedPhone = input.value.replace(/\D/g, '').slice(0, 10); // Clean input to allow only digits and limit to 10 characters
        this.phone = cleanedPhone; // Update phone number in component state
        console.log("212wsw",cleanedPhone);
        if(cleanedPhone !== ''){
        this.validatePhone(); // Validate the cleaned phone number
        }
    }

    

    // handleTermsServiceChange(event) {
    //     this.termsService = event.target.checked;
    //     this.validateNextButton(); 
    // }
    
    // handleTermsAgreeChange(event) {
    //     this.termsAgree = event.target.checked;
    //     this.validateNextButton(); 
    // }
    // validateNextButton() {
    //     this.isNextDisabled = !(this.termsService && this.termsAgree);
    // }
    
    check(){
        console.log("dofc",JSON.stringify(this.users));
        let contactIds = this.users.map(user => user.Id);
        console.log("con",JSON.stringify(contactIds));
        console.log("ds",JSON.stringify(this.selectedUserId));
    }
    handleSave(){
        this.goToMain();
       // Ensure morevehicles is an array of objects with Id field
    }

    goToMain(){
        let baseUrl = window.location.href;
    if(baseUrl.indexOf("/s/") !== -1) {
        let addBranchUrl = baseUrl.split("/s/")[0] + "/s/addbranch";
        window.location.href = addBranchUrl;
    }
    }
    
    handleDeleteVehicle(event) {
      const vehicleId = event.currentTarget.dataset.id;

    const deletedVehicleFromMoreVehiclesArray = this.morevehicles.find(veh => veh.Id === vehicleId);

    this.deletedVehicleIds.push(vehicleId);

    this.morevehicles = this.morevehicles.filter(veh => veh.Id !== vehicleId);

    if (deletedVehicleFromMoreVehiclesArray) {
        this.vehicles = [...this.vehicles, { label: deletedVehicleFromMoreVehiclesArray.Name, value: deletedVehicleFromMoreVehiclesArray.Id }];

    }}

    handleDeleteUser(event) {
      

        const userId = event.currentTarget.dataset.id;

    const deletedUserFromMoreUsersArray = this.moreusers.find(memb => memb.Id === userId);

    this.deletedVehicleIds.push(userId);

    this.moreusers = this.moreusers.filter(memb => memb.Id !== userId);

    if (deletedUserFromMoreUsersArray) {
        this.users = [...this.users, { label: deletedUserFromMoreUsersArray.Name, value: deletedUserFromMoreUsersArray.Id }];

    }
}


//    validatePhone (phone) {
//         if (phone.length === 10) {
//             this.template.querySelector('.phone').classList.remove('error'); 
//         } else {
//             this.template.querySelector('.phone').classList.add('error'); 
//         }
//     }

validatePhone() {
    const phoneRegex = /^\d{10}$/;
    return phoneRegex.test(this.phone);
}


    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }
 
    get filteredVehicles() {
        if (!this.searchTerm) {
            return this.vehicles;
        }
        return this.vehicles.filter(veh => {
            return veh.Name.toLowerCase().includes(this.searchTerm);
        });
    }

    
    get filteredUsers() {
        if (!this.searchTerm) {
            return this.users;
        }
        return this.users.filter(memb => {
            return memb.Name.toLowerCase().includes(this.searchTerm);
        });
    }
    
    handleVehicleSelect(event) {
        this.selectedVehicleId = event.currentTarget.dataset.id;
        console.log("arrat",JSON.stringify(this.vehicles));
        this.handleVehicleChange();
    }

    handleUserSelect(event) {
        this.selectedUserId = event.currentTarget.dataset.id;
        console.log("arrat",JSON.stringify(this.users));
        this.handleUserChange();
    }
    

    handleOutsideClick = (event) => {
        const dataDropElement = this.template.querySelector('.Inputs1');
        const listsElement = this.template.querySelector('.lists');

        if (
            dataDropElement &&
            !dataDropElement.contains(event.target) &&
            listsElement &&
            !listsElement.contains(event.target)
        ) {
            this.showList = false;
            this.showListUser = false;
            console.log("Clicked outside");
        }
    };

    handleInsideClick(event) {
        event.stopPropagation();
    }
   
    renderedCallback() {
        if (!this.outsideClickHandlerAdded) {
            document.addEventListener('click', this.handleOutsideClick);
            this.outsideClickHandlerAdded = true;
        }
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleOutsideClick);
    }

    
}