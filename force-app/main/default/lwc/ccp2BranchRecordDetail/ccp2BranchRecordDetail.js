import { LightningElement,track,api,wire } from 'lwc';
import Vehicle_StaticResource from '@salesforce/resourceUrl/CCP_StaticResource_Vehicle';
//import { refreshApex } from '@salesforce/apex';
import getBranchData from '@salesforce/apex/CCP2_userData.NewBranchDetails';
import getNullVehicles from '@salesforce/apex/CCP2_userData.VehicleWithoutAssociationDtl';
import deleteVehicles from '@salesforce/apex/CCP2_userData.unassociateVehicle';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AddVehicle from '@salesforce/apex/CCP2_userData.associateVehicle';
import UserList from '@salesforce/apex/CCP2_userData.userListDtl';
import AddUser from '@salesforce/apex/CCP2_userData.associateUser';
import deleteUser from '@salesforce/apex/CCP2_userData.unassociateUser';
import UpdateFields from '@salesforce/apex/CCP2_branchUpdate.updateBranchById';
import deletebranch from '@salesforce/apex/CCP2_BranchDeleteController.deleteBranchById';

//import Arrows from '@salesforce/resourceUrl/arrownew';


//labels 
import CCP2_LocationInformation from '@salesforce/label/c.CCP2_LocationInformation';
import CCP2_CompanyName from '@salesforce/label/c.CCP2_CompanyName';
import CCP2_BranchNumber from '@salesforce/label/c.CCP2_BranchNumber';
import CCP2_BranchName from '@salesforce/label/c.CCP2_BranchName';
import CCP2_Address from '@salesforce/label/c.CCP2_Address';
import CCP2_Contact from '@salesforce/label/c.CCP2_Contact';
import CCP2_AffiliatedVehicles from '@salesforce/label/c.CCP2_AffiliatedVehicles';
import CCP2_Users from '@salesforce/label/c.CCP2_Users';
import CCP2_ToEdit from '@salesforce/label/c.CCP2_ToEdit';
import CCP2_DeleteThisBranch from '@salesforce/label/c.CCP2_DeleteThisBranch';
import CCP2_Return from '@salesforce/label/c.CCP2_Return';
// import CCP2_BranchNo from '@salesforce/label/c.CCP2_BranchNumber';
import CCP2_Required from '@salesforce/label/c.CCP2_Required';
import CCP2_AddVehicles from '@salesforce/label/c.CCP2_AddVehicles';
import CCP2_AddUsers from '@salesforce/label/c.CCP2_AddUsers';
import CCP2_SelectAUser from '@salesforce/label/c.CCP2_SelectAUser';
import CCP2_SaveChanges from '@salesforce/label/c.CCP2_SaveChanges';
import CCP2_BackToMain from '@salesforce/label/c.CCP2_BackToMain';
import CCP2_WithoutHyphen from '@salesforce/label/c.CCP2_WIthoutHyphen';
import CCP2_PleaseSelect from '@salesforce/label/c.CCP2_PleaseSelect';
import CCP2_AssignMem from '@salesforce/label/c.CCP2_AssignNewMember';
import CCP2_AssignVeh from '@salesforce/label/c.CCP2_AssignNewVehicle';
import CCP2_PleaseEnter from '@salesforce/label/c.CCP2_PleaseEnter';
import CCP2_SelectedVehicle from '@salesforce/label/c.CCP2_SelectedVehicle';
import CCP2_SelectedMembers from '@salesforce/label/c.CCP2_SelectedMembers';






const BACKGROUND_IMAGE_PC = Vehicle_StaticResource + '/CCP_StaticResource_Vehicle/images/Main_Background.png';
const  arrowicon = Vehicle_StaticResource + '/CCP_StaticResource_Vehicle/images/arrow_under.png';

export default class Ccp2BranchRecordDetail extends LightningElement {

    labels = {
        CCP2_LocationInformation,
        CCP2_CompanyName,
        CCP2_BranchNumber,
        CCP2_BranchName,
        CCP2_Address,
        CCP2_Contact,
        CCP2_AffiliatedVehicles,
        CCP2_Users,
        CCP2_ToEdit,
        CCP2_DeleteThisBranch,
        CCP2_Return,
        CCP2_Required,
        CCP2_AddVehicles,
        CCP2_AddUsers,
        CCP2_SelectAUser,
        CCP2_SaveChanges,
        CCP2_BackToMain,
        CCP2_WithoutHyphen,
        CCP2_PleaseSelect,
        CCP2_AssignMem,
        CCP2_AssignVeh,
        CCP2_PleaseEnter,
        CCP2_SelectedVehicle,
        CCP2_SelectedMembers 
    };


    backgroundImagePC = BACKGROUND_IMAGE_PC;
    @track showDetails = true;
    @api branchId;
    @track showlist = false;
    @track CompanyName = '';
    @track TipNumber = '';
    @track BranchNumber = '';
    @track originalBranchName = '';
    @track MentionName = '';
    @track Address = '';
    @track Contact = '';
    @track OriginalAddress = '';
    @track OriginalContact = '';
    @track vehicle = [];
    @track contacts = [];
    @track branchName = '';
    @track deletedVehicleIds = [];
    @track deletedContactIds = [];
    @track showSpinner = false;
    @track vehicles = [];
    @track selectedVehicleId = '';
    @track morevehicles = [];
    @track moreContacts = [];
    @track selectedContactId = '';
    @track optcontacts = [];
    @track vehicleIds = [];
    @track showUserOpt = false;
    @track vehicletoPush = this.morevehicles;
    //for validations in inputs 
    @track branchNameClass = '';
    @track addressClass = '';
    @track contactClass = '';
    @track opts = true;
    @track main = true;
    outsideClickHandlerAdded = false;
    //@track dropdownVisible = false;
    @track selectedLabels = '';
    searchTerm = '';
    imgdrop = arrowicon;
    @track showList = false;
    
    
    @wire(getBranchData,{branchId: '$branchId'})BranchData({data,error}){
        if(data){
            console.log("mine",data);
            const branch = data.BranchDetails;
           // console.log("BrDATA",data);
           // console.log('Branch Details:', JSON.stringify(data));
            this.CompanyName = branch.Company ? branch.Company : "-";
            //this.TipNumber = branch.Tip_Number__c;
           // this.BranchNumber = branch.Branch_Number__c;
           this.Address = branch.Address ? branch.Address : null;
           // this.MentionName = branch.Mention_Name__c;
           this.Contact = branch.ContactNo ? branch.ContactNo : null;
            //this.vehicle = branch.vehicleBranch__r;
            //this.contacts = branch.Contact__r;
            this.branchName = branch.Name ? branch.Name : "-";
            //comparison variables
            this.originalBranchName = branch.Name;
            this.OriginalAddress = branch.Address;
            this.OriginalContact = branch.ContactNo;
            this.contacts = data.Contacts.map(contact => ({
                Name: contact.Name,
                Id: contact.Id
            }));
            console.log("con",JSON.stringify(this.contacts));
            this.vehicle = data.Vehicles.map(vehicle => ({
                Name: vehicle.Name,
                Id: vehicle.Id
            }));
           // console.log("ve",JSON.stringify(this.vehicle));
            this.showSpinner = false; 
        }
        else if(error){
            console.log(error);
            this.showSpinner = false; 
        }
    }

    // refreshData() {
    //     refreshApex(this.BranchDataResult);
    // }
    handlevehChange(event){
        event.stopPropagation();
        this.showlist = !this.showlist;
        if (this.vehicles.length === 0) {
            this.showlist = false;
        }
    }
    handleConChange(event){
        event.stopPropagation();
        this.showList = !this.showList;
        if (this.optcontacts.length === 0) {
            this.showList = false;
        }
    }

    handleInsideClick(event) {
        event.stopPropagation();
    }
    // toggleDropdown() {
    //     this.showlist = false;
    // }

    get hasContacts() {
        return this.contacts.length > 0 || this.moreContacts.length > 0;
    }

    get hasVehicles() {
        return this.vehicle.length > 0 || this.morevehicles.length > 0;
    }

    @wire(getNullVehicles,{branchId: '$branchId'}) wiredVehicles({ data, error }) {
        if (data) {
              // Create a Set of existing vehicle IDs for quick lookup
              this.vehicles = data.map(vehicle => {
                return { label: vehicle.Name, value: vehicle.Id };
            });
            console.log("newv",data);

        // Debug logs
        } else if (error) {
            console.error(error);
        }
    }
    @wire(UserList,{branchId: '$branchId'}) wiredUsers({ data, error }) {
        if (data) {
            // console.log("")
            //  console.log("userdata",data);
            this.optcontacts = data.map(contact => {
                return { label: contact.Name, value: contact.Id };
            });
           // console.log("vehmapata",this.vehicles);
            //  this.optcontacts = JSON.parse(JSON.stringify(this.optcontacts));
        } else if (error) {
            console.error(error);
        }
    }
   
    connectedCallback() {
        const link = document.createElement('link');
        link.href = 'https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@100..900&display=swap';
        link.rel = 'stylesheet';
        document.head.appendChild(link);
        this.template.host.style.setProperty('--dropdown-icon', `url(${this.imgdrop})`);
        requestAnimationFrame(() => {
            this.addCustomStyles();
        });
        //document.addEventListener('click', this.handleOutsideClick.bind(this));
        this.showSpinner = true;
    }
    // disconnectedCallback() {
    //     document.removeEventListener('click', this.handleOutsideClick.bind(this));
    // }
    handleOutsideClick = (event) => {
        const dataDropElement = this.template.querySelector('.dataDrop');
        const listsElement = this.template.querySelector('.lists');
        
        if (
            dataDropElement &&
            !dataDropElement.contains(event.target) &&
            listsElement &&
            !listsElement.contains(event.target)
        ) {
            this.showlist = false;
            //console.log("Clicked outside");
        }
    };
    handleOutsideClick2 = (event) => {
        const dataDropElement = this.template.querySelector('.dataDrop2');
        const listsElement = this.template.querySelector('.lists2');
        
        if (
            dataDropElement &&
            !dataDropElement.contains(event.target) &&
            listsElement &&
            !listsElement.contains(event.target)
        ) {
            this.showList = false;
            //console.log("Clicked outside");
        }
    };
   
    renderedCallback() {
        if (!this.outsideClickHandlerAdded) {
            document.addEventListener('click', this.handleOutsideClick.bind(this));
            document.addEventListener('click', this.handleOutsideClick2.bind(this));
            this.outsideClickHandlerAdded = true;
        }
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleOutsideClick.bind(this));
    }

    handleChange() {
        this.showSpinner = true;
        setTimeout(() => {
            this.showDetails = !this.showDetails;
            this.showSpinner = false;
        }, 1000); 
    }
    // checks(){
    //     console.log('dvid:', JSON.stringify(this.deletedVehicleIds));
    //     console.log('dcid:', JSON.stringify(this.deletedContactIds));
    // }
    handleDeleteVehicle(event) {
        const vehicleId = event.currentTarget.dataset.id;
   // console.log("Deleting vehicle with ID:", vehicleId);

    const deletedVehicleFromVehicleArray = this.vehicle.find(veh => veh.Id === vehicleId);
    if (deletedVehicleFromVehicleArray) {
        this.vehicles = [...this.vehicles, { label: deletedVehicleFromVehicleArray.Name, value: deletedVehicleFromVehicleArray.Id }];
       // console.log("Vehicle re-added to selection list from `vehicle` array:", JSON.stringify(this.vehicles));
    }

    const deletedVehicleFromMoreVehiclesArray = this.morevehicles.find(veh => veh.Id === vehicleId);
    if (deletedVehicleFromMoreVehiclesArray && !deletedVehicleFromVehicleArray) {
        this.vehicles = [...this.vehicles, { label: deletedVehicleFromMoreVehiclesArray.Name, value: deletedVehicleFromMoreVehiclesArray.Id }];
        //console.log("Vehicle re-added to selection list from `morevehicles` array:", JSON.stringify(this.vehicles));
    }

    this.deletedVehicleIds.push(vehicleId);

    this.vehicle = this.vehicle.filter(veh => veh.Id !== vehicleId);
    this.morevehicles = this.morevehicles.filter(veh => veh.Id !== vehicleId);
    this.selectedVehicleId = '';


    }

    //on clicking on cross button in contacts div in edit page
    handleDeleteContact(event) {
        const contactId = event.currentTarget.dataset.id;

        const deletedContactFromContactsArray = this.contacts.find(contact => contact.Id === contactId);
        if (deletedContactFromContactsArray) {
            this.optcontacts = [...this.optcontacts, { label: deletedContactFromContactsArray.Name, value: deletedContactFromContactsArray.Id }];
        }
    
        const deletedContactFromMoreContactsArray = this.moreContacts.find(contact => contact.Id === contactId);
        if (deletedContactFromMoreContactsArray && !deletedContactFromContactsArray) {
            this.optcontacts = [...this.optcontacts, { label: deletedContactFromMoreContactsArray.Name, value: deletedContactFromMoreContactsArray.Id }];
        }
    
        this.deletedContactIds.push(contactId);
    
        this.contacts = this.contacts.filter(contact => contact.Id !== contactId);
        this.moreContacts = this.moreContacts.filter(contact => contact.Id !== contactId);
    
        this.selectedContactId = ''; 
    }


 //on Saving the data on edit page
  async handleSave() {
    try {
        const branchInput = this.template.querySelector('input[name="branch"]');
        let allValid = true;

        // Validate the branch input
        if (!branchInput.value) {
            branchInput.classList.add('invalid-input');
            branchInput.setCustomValidity('この項目は必須です');
            branchInput.reportValidity();
            allValid = false;
        } else {
            branchInput.classList.remove('invalid-input');
            branchInput.setCustomValidity('');
            branchInput.reportValidity();
        }
            // if (this.Contact.length !== 0 && this.Contact.length < 10) {
            //     const contactInput = this.template.querySelector('input[name="contactNumber"]');
            //     contactInput.classList.add('invalid-input');
            //     contactInput.setCustomValidity('連絡先番号は正確に 10 桁である必要があります');
            //     contactInput.reportValidity();
            //     allValid = false;
            // } else {
            //     const contactInput = this.template.querySelector('input[name="contactNumber"]');
            //     contactInput.classList.remove('invalid-input');
            //     contactInput.setCustomValidity('');
            //     contactInput.reportValidity();
            // }

            if (!allValid) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        //title: 'Error',
                        message: 'すべての項目を入力してください。',
                        variant: 'error',
                    }),
                );
                return;
            }
            
        const actions = [];
        if (this.deletedVehicleIds.length > 0) {
            actions.push(deleteVehicles({ vehicles: this.deletedVehicleIds, branchId: this.branchId}));
        }

        if (this.deletedContactIds.length > 0) {
            actions.push(deleteUser({ Contact: this.deletedContactIds, branchId: this.branchId}));
        }

        if (actions.length > 0) {
            await Promise.all(actions);
        }

        if (this.morevehicles.length > 0) {
            const vehicleIdsToAdd = this.morevehicles.map(vehicle => vehicle.Id);
            actions.push(AddVehicle({ vehicles: vehicleIdsToAdd, branch: this.branchId }));
        }

        if (this.moreContacts.length > 0) {
            const ContactIdsToAdd = this.moreContacts.map(vehicle => vehicle.Id);
            actions.push(AddUser({ Contact: ContactIdsToAdd, branch: this.branchId }));
        }

        if (this.branchName !== this.originalBranchName ||
            this.Address !== this.originalAddress ||
            this.Contact !== this.originalContact) {
            actions.push(UpdateFields({
                branchId: this.branchId,
                branchName: this.branchName,
                address: this.Address,
                contactNo: this.Contact
            }));
        }
        if (actions.length > 0) {
            console.log('Actions length:', actions.length);
            await Promise.all(actions);
            this.dispatchEvent(
                new ShowToastEvent({
                   // title: 'Success',
                    message: 'ブランチが正常に編集されました',
                    variant: 'success',
                }),
            );
            this.goTodetail();
        } else {
            console.log("going");
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         //title: 'No Changes',
            //         message: '保存する変更はありません',
            //         variant: 'info',

            //     }),
            // );
            this.goTodetail(); 
        }

    } catch (error) {
        this.dispatchEvent(
            new ShowToastEvent({
               // title: 'Error',
               message: error.body ? `変更を保存できませんでした: ${error.body.message}` : '変更を保存できませんでした',
               variant: 'error',
            }),
        );
    }
    }
    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }
    get filteredVehicles() {
        if (!this.searchTerm) {
            return this.vehicles;
        }
        return this.vehicles.filter(veh => {
            return veh.label.toLowerCase().includes(this.searchTerm);
        });
    }
    handleSearchCon(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }
    get filteredContacts() {
        if (!this.searchTerm) {
            return this.optcontacts;
        }
        return this.optcontacts.filter(veh => {
            return veh.label.toLowerCase().includes(this.searchTerm);
        });
    }

     //on adding of vehicles 
    handleVehicleSelect(event) {
        this.selectedVehicleId = event.currentTarget.dataset.id;
        this.handleVehicleChange();
    
    }
    closeList(){
        this.showlist = false;
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
            if (this.vehicles.length === 0) {
                this.showlist = false;
            }
        
    }
     //on adding of contacts
    handleContactSelect(event) {
        this.selectedContactId = event.currentTarget.dataset.id;
        this.handleContactChange();
    
    }
    handleContactChange() {
        let selectedContact = '';
    for (let i = 0; i < this.optcontacts.length; i++) {
        if (this.optcontacts[i].value === this.selectedContactId) {
            selectedContact = this.optcontacts[i];
            this.optcontacts.splice(i, 1);
            break;
        }
    }
    if (selectedContact) {
        this.moreContacts.push({ Id: selectedContact.value, Name: selectedContact.label });
    }
    this.selectedContactId = null;
    if (this.optcontacts.length === 0) {
        this.showList = false;
    }     
    }

    //for edit page Inputs 
    handleBranchChange(event) {
        this.branchName = event.target.value;
        //this.branchNameClass = this.branchName ? '' : 'invalid-input';@not used but in future if need
        console.log("1br",this.branchName);
    }
    handleAddressChange(event) {
        this.Address = event.target.value;
       // this.addressClass = this.Address ? '' : 'invalid-input'; @not used but in future if need
        console.log("2br",this.Address);
    }
    
    
    handleContactNoChange(event) {
        this.Contact = event.target.value;
       // this.contactClass = this.Contact ? '' : 'invalid-input'; @not used but in future if need
        //console.log("3br",this.Contact);
        const input = event.target.value;
        const numericValue = input.replace(/\D/g, ''); // Remove non-numeric characters
    
        if (numericValue.length <= 10) {
            this.Contact = numericValue;
            this.contactClass = this.Contact ? '' : 'invalid-input';
            console.log("Contact:", this.Contact);
        } else {
            // If input length exceeds 10, truncate it
            this.Contact = numericValue.slice(0, 10);
            this.contactClass = this.Contact ? '' : 'invalid-input';
            console.log("Contact (truncated):", this.Contact);
        }
    }

    //contact input validation
    handleInput(event) {
        const input = event.target;
        input.value = input.value.replace(/\D/g, '').slice(0, 16);
    }

    //function to redirect to branch page
    goToMain(){
        let baseUrl = window.location.href;
    if(baseUrl.indexOf("/s/") !== -1) {
        let addBranchUrl = baseUrl.split("/s/")[0] + "/s/addbranch";
        window.location.href = addBranchUrl;
    }
    }
   
    //going to detail page
    goTodetail(){
        this.showDetails = !this.showDetails;
        window.scrollTo(0, 0);
    }

    //on deleting the branch(Whole branch removed)
    deletebranch(){
        deletebranch({ branchId: this.branchId })
        .then(() => {
            this.goToMain();
            this.dispatchEvent(
                new ShowToastEvent({
                    //title: 'Success',
                    message: 'ブランチが正常に削除されました',
                    variant: 'success',
                })
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    //title: 'Error',
                    message: 'ブランチの削除中にエラーが発生しました:' + error.body.message,
                    variant: 'error',
                })
            );
        });
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
}