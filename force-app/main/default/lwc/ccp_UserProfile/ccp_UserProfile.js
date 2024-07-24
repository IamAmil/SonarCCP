/*
 * @Author: Huanghao Tu
 * @Date: 2022-10-12 12:48:43
 * @LastEditTime: 2023-01-03 09:29:07
 * @Description: 基本情報
 */
import { LightningElement,wire,track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Profile_StaticResource from '@salesforce/resourceUrl/CCP_StaticResource_Vehicle';
import getContactData from '@salesforce/apex/CCP_UserProfileCtrl.getContactData';
import updateContactData from '@salesforce/apex/CCP_UserProfileCtrl.updateContactData';
import checkManagerUser from "@salesforce/apex/CCP_HeaderController.checkManagerUser";
import getUsers from '@salesforce/apex/CCP2_userController.adminUser';


import branchContactAdd from "@salesforce/apex/CCP2_userController.branchContactAdd";
import branchContactDelete from "@salesforce/apex/CCP2_userController.branchContactDelete";
import branchdetails from "@salesforce/apex/CCP2_userData.userBranchDtl";
import updateUser from "@salesforce/apex/CCP2_userController.updateRecords";
import userTypeJudgment from '@salesforce/apex/CCP_UserProfileCtrl.userTypeJudgment';
import permissionDBCheck from '@salesforce/apex/CCP_UserUtil.permissionDBCheck';
import permissionEICheck from '@salesforce/apex/CCP_UserUtil.permissionEICheck';
import userFDPCheck from '@salesforce/apex/CCP_UserUtil.userFDPCheck';
import getBaseInfoByUserId from '@salesforce/apex/CCP_HomeCtrl.getBaseInfoByUserId';
import Vehicle_StaticResource from '@salesforce/resourceUrl/CCP2_Resources';
import getBasicInfo from '@salesforce/apex/CCP2_userController.userBasicInfo';
import oldnewadmin from '@salesforce/apex/CCP2_userController.createAdmin';
import getbranchdetails from "@salesforce/apex/CCP2_userData.UnAssociatedBranch";
import { getRecord } from 'lightning/uiRecordApi';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
import Id from '@salesforce/user/Id';
import FirstName from '@salesforce/schema/Contact.FirstName';

const  arrowicon = Vehicle_StaticResource + '/CCP2_Resources/Common/arrow_under.png';

const BACKGROUND_IMAGE_PC = Profile_StaticResource + '/CCP_StaticResource_Vehicle/images/Main_Background.png';
const BACKGROUND_IMAGE_MOBILE = Profile_StaticResource + '/CCP_StaticResource_AddUser/images/register_img_hero.png';

const truck1 = Vehicle_StaticResource + "/CCP2_Resources/User/truckImg1.png";
const truck2 = Vehicle_StaticResource + "/CCP2_Resources/User/truckImg2.png";
const truck3 = Vehicle_StaticResource + "/CCP2_Resources/User/truckImg3.png";

export default class Ccp_UserProfile extends LightningElement {
    backgroundImagePC = BACKGROUND_IMAGE_PC;
    backgroundImageMobile = BACKGROUND_IMAGE_MOBILE;

    @track showModal = false;
    @track searchTerm = "";
    @track placeholdershow = true;
    refreshTokenInt = 0;
    refreshTokenInt2 = 10;
    imgdrop = arrowicon;
    userId = Id;
    truckpic1 = truck1;
    truckpic2 = truck2;
    truckpic3 = truck3;
    @track branchData;
    @track branch = [];
    @track allUserLoader = false;
    @track showcancelModaledit = false;
    @track showstep2 = false;
    @track showcanceledit = false;
    @track showagreeModal = false;
    @track showeditscreen = false;
    @track showcancelModal = false;
    @track agreeChange = false;
    @track isDropdownOpen = false;
    @track selectedValue = '';
    @track selectedId = '';
    @track userList = []; 
    @track branchoptions = [];
    @track formDataArray = [];
    selectedUserId = '';
    @track formData = {}; 
    @track userInfo ={
        id: null,
        firstName: null,
        lastName: null,
        firstNameKana: null,
        lastNameKana: null,
        email: null,
        accountname: null,
        siebelAccountCode: null,
        MobilePhone: null,
        Department: null,
        Employee_Code: null,
        Phone:null,
        firstNameKana__c:null,
        lastNameKana__c:null,
        Title:null,
        EmployeeCode: null
    };
    @track error;
    @track branchfromjunction = [];
    @track newusershow = false;
    selectedContactId; 
    contactId;
    contactData;
    workdayStart;
    workdayEnd;
    holidayStart;
    holidayEnd;
    // isNotReceiveByPhone;
    // isNotReceiveByPostcard;
    defaultDisplay;
    @track isLoading = false;
    updateSuccess = false;
    vehicleShow = false;
    isFDPShow = true;
    showchangeAdmin = false;
    showBasicinfo = true;
    showconfModal = false;
    showstep1 = false;
    showstep3 = false;
    @track showlist = false;
    @track deletedBranchIds = [];

    userDetailData = {
        id: null,
        firstName: null,
        lastName: null,
        firstNameKana: null,
        lastNameKana: null,
        email: null,
        accountname: null,
        siebelAccountCode: null,
        MobilePhone: null,
        Department: null,
        Employee_Code: null,
        Phone:null,
        firstNameKana__c:null,
        lastNameKana__c:null,
        Title:null,
        EmployeeCode: null
      };

    contactClassFirstName = "";
    contactClassLastName = "";
    contactClassFKanaName = "";
    contactClassLKanaName = "";
    contactClassEmail = "";
    contactClassTelephone = "";
    contactClassCellPhone = "";

    InputFirstName = "";
    InputLastName = "";
    InputFKanaName = "";
    InputLKanaName = "";
    InputEmail = "";
    InputTelephone = "";
    InputCellPhone = "";
    InputEmpCode = "";
    InputDepartment = "";
    InputPost = "";


    @wire(getbranchdetails, { contactId: "$contactId" }) wiredBranches({
        data,
        error
      }) {
        if (data) {
          this.branchoptions = data.map((vehicle) => {
            return { label: vehicle.Name, value: vehicle.Id };
          });
        } else if (error) {
          console.error(error);
        }
      }

      @wire(branchdetails, {
        User: "$contactId",
        refresh: "$refreshTokenInt2"
      })
      wiredbranches2({ data, error }) {
        if (data) {
          console.log("branchdetails wire:-", data, this.refreshTokenInt2);
          this.branchfromjunction = data.map((branch) => ({
            Name: branch.Name,
            Id: branch.Id
          }));
        } else {
          console.error("error in fetching branches from new", error);
        }
      }
    get options() {
        let options = [];
        for(let a = 0; a < 24; a++){
            if(a < 10){
                a = '0' + a;
            } else {
                a = a.toString();
            }
            options = [...options,{
                label: a,
                value: a
            }];
        }
        return options;
    }

    connectedCallback(){
        this.checkManagerUser();
        this.template.host.style.setProperty('--dropdown-icon', `url(${this.imgdrop})`);
        requestAnimationFrame(() => {
            this.addCustomStyles();
        });
        
        this.userTypeJudgment();
        this.getContactData();
        permissionDBCheck({uId:Id}).then(res =>{
            if(res){
                this.vehiclereservation = true;
            }
        });
        permissionEICheck({uId:Id}).then(res =>{
            if(res){
                this.requestbook = true;
            }
        });
        userFDPCheck({uId:Id}).then(res =>{
            if(!res){
                this.vehicleShow = true;
            }
        });
        getBaseInfoByUserId({uId:Id}).then(res =>{
            if(res.isFDP != undefined){
                this.isFDP = res.isFDP;
            }
            if(this.isFDP){
                this.isFDPShow = false;
            }
        });
    }


    // renderedCallback(){
    //     const selectElement = this.template.querySelector('select');
    //     console.log("query selector in select",selectElement)
    //     if (selectElement.value == '選択してください') {
    //         selectElement.classList.add('placeholder-selected');
    //     } else {
    //         selectElement.classList.remove('placeholder-selected');
    //     }
    // }

    @wire(getRecord, {
        recordId: '$userId',
        fields: [CONTACT_ID_FIELD]
    })
    userRecord({ error, data }) {
        if (data) {
            this.contactId = data.fields.ContactId.value;
            console.log('Contact ID adminnnnnnnn:', this.contactId);
        } else if (error) {
            console.error('Error fetching user record:', error);
        }
    }

    // @wire(getRecord, {
    //     recordId: '$selectedUserId',
    //     fields: [CONTACT_ID_FIELD]
    // })
    // userRecord({ error, data }) {
    //     if (data) {
    //         this.selectedContactId = data.fields.ContactId.value;
    //         console.log('selectd Contact ID:', this.selectedContactId);
    //     } else if (error) {
    //         console.error('Error fetching user record:', error);
    //     }
    // }


    
    
                
    @wire(getBasicInfo,{ContactId:'$contactId',refresh: "$refreshTokenInt"})
    fetUserInfo({data,error}){
        if(data){
          this.branchData = data;
            // let contactData = [];
            // if(data != null){
                // let accountData = data.Account;
                this.userDetailData = {
                    accountname: data.AccountName == null ? '-' : data.AccountName,
                    firstName: data.FirstName == null ? '-' : data.FirstName,
                    lastName: data.LastName == null ? '-' : data.LastName,
                    firstNameKana: data.FirstNameKana == null ? '-' : data.FirstNameKana,
                    lastNameKana: data.LastNameKana == null ? '-' : data.LastNameKana,
                    siebelAccountCode: data.AccountSiebelAccountCode == null ? '-' : data.AccountSiebelAccountCode,
                    id: data.Id == null ? '-' : data.Id,
                    email: data.Email == null ? "-" : data.Email,
                    MobilePhone: data.MobilePhone == null ? '-' : data.MobilePhone,
                    Department: data.Department == null ? '-' : data.Department,
                    Employee_Code: data.EmployeeCode == null ? '-' : data.EmployeeCode,
                    Phone: data.Phone == null ? '-' : data.Phone,
                    Title: data.Title == null ? '-' : data.Title,
                    Branchs: data.BranchNames.length > 0 ? data.BranchNames : ['-']
                    // Branchs: data.BranchNames.length == ['-'] ? [{Name:'-'}] : data.BranchNames
                }
                console.log("userrrrhelllooooodata",this.userDetailData);
                // the time field return the milliseconds so the time need divided by 3600000
                this.workdayStart = data.MostLikelyWeekdayStartTimesForAppoint == null ? '' : this.getTime(data.MostLikelyWeekdayStartTimesForAppoint);
                console.log("math floor in save week start",data.MostLikelyWeekdayStartTimesForAppoint)
                console.log("start start inside user user",this.workdayStart);
                this.workdayEnd = data.MostLikelyWeekdayEndTimesForAppoint == null ? '' : this.getTime(data.MostLikelyWeekdayEndTimesForAppoint);
                console.log("math floor in save week end",data.MostLikelyWeekdayEndTimesForAppoint)
                console.log("end week start inside user user",this.workdayEnd);
                this.holidayStart = data.MostLikelyHolidayStartTimesForAppoint == null ? '' : this.getTime(data.MostLikelyHolidayStartTimesForAppoint);
                console.log("math floor in save holi start",data.MostLikelyHolidayStartTimesForAppoint)
                console.log("start holi start inside user user",this.holidayStart);
                this.holidayEnd = data.MostLikelyHolidayEndTimesForAppoint == null ? '' : this.getTime(data.MostLikelyHolidayEndTimesForAppoint);
                console.log("math floor in save holi end",data.MostLikelyHolidayEndTimesForAppoint)
                console.log("end holi inside user user",this.holidayEnd);


                this.InputFirstName = data.FirstName == null ? '' : data.FirstName;
                this.InputLastName = data.LastName == null ? '' : data.LastName;
                this.InputFKanaName = data.FirstNameKana == null ? '' : data.FirstNameKana;
                this.InputLKanaName = data.LastNameKana == null ? '' : data.LastNameKana;
                this.InputDepartment = data.Department == null ? '' : data.Department;
                this.InputEmail = data.Email == null ? '' : data.Email;
                this.InputEmpCode = data.EmployeeCode == null ? '' : data.EmployeeCode;
                this.InputCellPhone = data.MobilePhone == null ? '' : data.MobilePhone;
                this.InputPost = data.Title == null ? '' : data.Title;
                this.InputTelephone = data.Phone == null ? '' : data.Phone;

    //             this.defaultDisplay = {
    //                 workdayStart: this.workdayStart,
    //                 workdayEnd: this.workdayEnd,
    //                 holidayStart: this.holidayStart,
    //                 holidayEnd: this.holidayEnd,
    //                 // isNotReceiveByPhone: false,
    //                 // isNotReceiveByPostcard: false
    //             };
    // //             // if(this.defaultDisplay.workdayStart != null){
    // //             //     this.template.querySelector('[name="workdayStart"]').selectedIndex = Number(this.defaultDisplay.workdayStart) + 1;
    // //             // } else {
    // //             //     this.template.querySelector('[name="workdayStart"]').selectedIndex = 0;
    // //             // }
    // //             // if(this.defaultDisplay.workdayEnd != null){
    // //             //     this.template.querySelector('[name="workdayEnd"]').selectedIndex = Number(this.defaultDisplay.workdayEnd) + 1;
    // //             // } else {
    // //             //     this.template.querySelector('[name="workdayEnd"]').selectedIndex = 0;
    // //             // }
    // //             // if(this.defaultDisplay.holidayStart != null){
    // //             //     this.template.querySelector('[name="holidayStart"]').selectedIndex = Number(this.defaultDisplay.holidayStart) + 1;
    // //             // } else {
    // //             //     this.template.querySelector('[name="holidayStart"]').selectedIndex = 0;
    // //             // }
    // //             // if(this.defaultDisplay.holidayEnd != null){
    // //             //     this.template.querySelector('[name="holidayEnd"]').selectedIndex = Number(this.defaultDisplay.holidayEnd) + 1;
    // //             // } else {
    // //             //     this.template.querySelector('[name="holidayEnd"]').selectedIndex = 0;
    // //             // }
    // //             // this.contactData = contactData;
            // }
        }else if(error){
            console.log("error,userrrsss",error);
        }
    }

    // @wire(getBasicInfo,{ContactId:'$selectedContactId'})
    // fetchnewuserInfo({data,error}){
    //     if(data){
    //         console.log("selected user info",data);
    //     }else if(error){
    //         console.log("errorss",error);
    //     }
    // }

    @wire(getUsers)
    Unassouser({data,error}){
        if(data){
            console.log("unassociated user",data);
            this.userList = data.map(Contact => {
                return { label: Contact.Name, value: Contact.Id };});;
                console.log("user listtttt",JSON.stringify(this.userList));
        }else if(error){
            console.log("error,unassociated user",error)
        }
    }


    getContactData(){
        getContactData().then(data => {
            let contactData = [];
            if(data != null){
                console.log("data",data);
                let accountData = data.Account;
                contactData = [{
                    id: data.Id,
                    firstName: data.FirstName,
                    lastName: data.LastName,
                    firstNameKana: data.firstNameKana__c,
                    lastNameKana: data.lastNameKana__c,
                    department: data.Department,
                    title: data.Title,
                    email: data.Email,
                    phone: data.Phone,
                    mobilePhone: data.MobilePhone,
                    accountName: accountData.Name,
                    accountCode: accountData.siebelAccountCode__c
                }];
                // the time field return the milliseconds so the time need divided by 3600000
                this.workdayStart = this.getTime(data.mostLikelyWeekdayStartTimesForAppoint__c);
                console.log("start start",this.workdayStart);
                this.workdayEnd = this.getTime(data.mostLikelyWeekdayEndTimesForAppoint__c);
                this.holidayStart = this.getTime(data.mostLikelyHolidayStartTimesForAppoint__c);
                this.holidayEnd = this.getTime(data.mostLikelyHolidayEndTimesForAppoint__c);
                this.defaultDisplay = {
                    workdayStart: this.workdayStart,
                    workdayEnd: this.workdayEnd,
                    holidayStart: this.holidayStart,
                    holidayEnd: this.holidayEnd,
                    // isNotReceiveByPhone: false,
                    // isNotReceiveByPostcard: false
                };
    //             // if(this.defaultDisplay.workdayStart != null){
    //             //     this.template.querySelector('[name="workdayStart"]').selectedIndex = Number(this.defaultDisplay.workdayStart) + 1;
    //             // } else {
    //             //     this.template.querySelector('[name="workdayStart"]').selectedIndex = 0;
    //             // }
    //             // if(this.defaultDisplay.workdayEnd != null){
    //             //     this.template.querySelector('[name="workdayEnd"]').selectedIndex = Number(this.defaultDisplay.workdayEnd) + 1;
    //             // } else {
    //             //     this.template.querySelector('[name="workdayEnd"]').selectedIndex = 0;
    //             // }
    //             // if(this.defaultDisplay.holidayStart != null){
    //             //     this.template.querySelector('[name="holidayStart"]').selectedIndex = Number(this.defaultDisplay.holidayStart) + 1;
    //             // } else {
    //             //     this.template.querySelector('[name="holidayStart"]').selectedIndex = 0;
    //             // }
    //             // if(this.defaultDisplay.holidayEnd != null){
    //             //     this.template.querySelector('[name="holidayEnd"]').selectedIndex = Number(this.defaultDisplay.holidayEnd) + 1;
    //             // } else {
    //             //     this.template.querySelector('[name="holidayEnd"]').selectedIndex = 0;
    //             // }
                this.contactData = contactData;
            }
        }).catch(error => {
            console.log('errors:' + JSON.stringify(error));    
        })
    }

    // get the selected date
    handleTimeSelection(event){
        let selectName = event.target.name;
        let selectValue = event.target.value;
        if(selectName == 'workdayStart'){
            this.workdayStart = selectValue;
        } else if(selectName == 'workdayEnd'){
            this.workdayEnd = selectValue;
        } else if(selectName == 'holidayStart'){
            this.holidayStart = selectValue;
        } else if(selectName == 'holidayEnd'){
            this.holidayEnd = selectValue;
        }
        this.saveButtonDisable();
    }

    // get the checked information
    // handleCheckboxChange(event){
    //     let checkName = event.target.name;
    //     let isChecked = event.target.checked;
    //     if(checkName == 'isNotReceiveByPhone'){
    //         this.isNotReceiveByPhone = isChecked;
    //     } else if(checkName == 'isNotReceiveByPostcard'){
    //         this.isNotReceiveByPostcard = isChecked;
    //     }
    //     this.saveButtonDisable();
    // }
    
    // back to home page
    navigateToHome() {
        let baseUrl = window.location.href;
        let homeUrl;
        if(baseUrl.indexOf("/s/") != -1) {
            homeUrl = baseUrl.split("/s/")[0] + '/s/';
        }
        window.location.href = homeUrl;
    }
    
    userTypeJudgment(){
        userTypeJudgment().then(data => {
            // console.log('data:' + data);
            if(!data){
                this.navigateToHome();
            }
        }).catch(error => {
            console.log('userTypeJudgment errors:' + JSON.stringify(error)); 
        })
    }
    closemainmodal(){
        this.showBasicinfo = false;
    }

    // save and update contact
    saveClick(){
        // display Loading Screen
        this.isLoading = true;
        let inputData = {
            workdayStart: Math.floor(Number(this.workdayStart)), 
            workdayEnd: Math.floor(Number(this.workdayEnd)), 
            holidayStart: Math.floor(Number(this.holidayStart)),
            holidayEnd: Math.floor(Number(this.holidayEnd)), 
            // isNotReceiveByPhone: this.isNotReceiveByPhone, 
            // isNotReceiveByPostcard: this.isNotReceiveByPostcard
        };
        updateContactData({inputDataStr: JSON.stringify(inputData)}).then(result=>{
            if(result != null){
                this.template.querySelector('[name="saveButton"]').className = 'primary_btn--m disabled';
                // display value reassignment
                this.defaultDisplay = {
                    workdayStart: this.workdayStart,
                    workdayEnd: this.workdayEnd,
                    holidayStart: this.holidayStart,
                    holidayEnd: this.holidayEnd,
                    // isNotReceiveByPhone: false,
                    // isNotReceiveByPostcard: false
                };
                let title = '保存が完了しました。';
                this.toast(title);
                this.isLoading = false;
            }
        }).catch(error => {
            console.log('updateContactError:' + JSON.stringify(error));
            this.isLoading = false;
        })
    }
    
    saveButtonDisable(){
        let workdayStart = this.defaultDisplay.workdayStart;
        let workdayEnd = this.defaultDisplay.workdayEnd;
        let holidayStart = this.defaultDisplay.holidayStart;
        let holidayEnd = this.defaultDisplay.holidayEnd;
        if(this.workdayStart == workdayStart && this.workdayEnd == workdayEnd 
            && this.holidayStart == holidayStart && this.holidayEnd == holidayEnd){
            this.template.querySelector('[name="saveButton"]').className = 'primary_btn--m disabled';
        } else{
            this.template.querySelector('[name="saveButton"]').className = 'primary_btn--m';
        }
    }

    getTime(timeValue){
        let time;
        if(timeValue != null){
            if(timeValue / 3600000 < 10){
                time = '0' + (timeValue / 3600000);
            } else{
                time = (timeValue / 3600000).toString();
            }
        } else{
            time = null;
        }
        return time;
    }


    toInquiryPage(){
        let baseUrl = window.location.href;
        let inquiryUrl;
        if(baseUrl.indexOf("/s/") != -1) {
            inquiryUrl = baseUrl.split("/s/")[0] + '/s/inquiry';
        }
        window.open(inquiryUrl);
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        });
        this.dispatchEvent(toastEvent);
    }
    handlechangeadmin(){
        console.log("inside change admin",this.showchangeAdmin);
        this.showconfModal = true;
        // this.showBasicinfo = true;
        console.log("inside change admin 2",this.showchangeAdmin);
    }


    close(){
        // const closeEvent = new CustomEvent('closemember');
        // console.log("inside close")
        // this.dispatchEvent(closeEvent);

            const closeEvent = new CustomEvent('closemember', {
                bubbles: true,
                composed: true
            });
            console.log('Dispatching closem event');
            this.dispatchEvent(closeEvent);
        
    }
    open() {
      // const openEvent = new CustomEvent('openmember');
      // console.log("inside open")
      // this.dispatchEvent(openEvent);
  
      const openEvent = new CustomEvent('openmember', {
          bubbles: true,
          composed: true
      });
      console.log('Dispatching openmember event');
    }
    handleYes(){
        this.showconfModal = false;
        this.showBasicinfo = false;
        this.showchangeAdmin = true;
        this.showstep1 = true;
        this.close();
    }
    handleNo(){
        this.showBasicinfo = true;
        this.showconfModal = false;
    }
    // handleChange(event) {
    //     this.selectedUserId =  event.currentTarget.dataset.id;
    //     console.log("Selected User ID:", this.selectedUserId);
    //     const selectedUser = this.userList.find(user => user.value === this.selectedUserId);
    //     if (selectedUser) {
    //         this.selectedValue = selectedUser.label;
    //         this.selectedId = selectedUser.value;
    //         console.log("selected value", this.selectedValue);

    //         this.userList = this.userList.filter(user => user.value !== this.selectedUserId);
    //     }
    //     this.isDropdownOpen = false;
    //     this.fetchUserInfo();
    //     this.newusershow = true;
    // }

    handleChange(event) {
      // Handle the change event when a user is selected
      const newSelectedUserId = event.currentTarget.dataset.id;
      console.log("New Selected User ID:", newSelectedUserId);
  
      // Find the new selected user in the userList
      const newSelectedUser = this.userList.find(user => user.value === newSelectedUserId);
      if (newSelectedUser) {
          // If there was a previously selected user, add it back to the userList
          if (this.selectedUserId) {
              const previousSelectedUser = {
                  value: this.selectedUserId,
                  label: this.selectedValue
              };
              this.userList = [...this.userList, previousSelectedUser];
          }
  
          // Update the currently selected user details
          this.selectedUserId = newSelectedUserId;
          this.selectedValue = newSelectedUser.label;
          console.log("New selected value:", this.selectedValue);
  
          // Remove the newly selected user from the userList
          this.userList = this.userList.filter(user => user.value !== newSelectedUserId);
      }
  
      // Close the dropdown and fetch user info
      this.isDropdownOpen = false;
      this.fetchUserInfo();
      this.newusershow = true;
  }
  

    fetchUserInfo() {
        if (this.selectedUserId) {
            getBasicInfo({ContactId: this.selectedUserId})
                .then(result => {
                    this.userInfo = {
                    accountname: result.AccountName == null ? '-' : result.AccountName,
                    firstName: result.FirstName == null ? '-' : result.FirstName,
                    lastName: result.LastName == null ? '-' : result.LastName,
                    firstNameKana: result.FirstNameKana == null ? '-' : result.FirstNameKana,
                    lastNameKana: result.LastNameKana == null ? '-' : result.LastNameKana,
                    siebelAccountCode: result.AccountSiebelAccountCode == null ? '-' : result.AccountSiebelAccountCode,
                    id: result.Id == null ? '-' : result.Id,
                    email: result.Email == null ? "-" : result.Email,
                    MobilePhone: result.MobilePhone == null ? '-' : result.MobilePhone,
                    Department: result.Department == null ? '-' : result.Department,
                    Employee_Code: result.EmployeeCode == null ? '-' : result.EmployeeCode,
                    Phone: result.Phone == null ? '-' : result.Phone,
                    Title: result.Title == null ? '-' : result.Title,
                    Branchs: result.BranchNames.length > 0 ? result.BranchNames : ['-']
                    // Branchs: result.BranchNames == undefined ? [{Name:'-'}] : result.BranchNames
                    };
                    console.log("selectd user info",JSON.stringify(this.userInfo));
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    console.log("error in selected user",error)
                    this.userInfo = undefined;
                });
        }
    }


    toggleDropdown() {
        if(this.userList.length != 0){
            this.isDropdownOpen = !this.isDropdownOpen;
        }
    }

    handleMouseOver(event) {
        event.currentTarget.style.backgroundColor = 'lightgrey';
        event.currentTarget.style.color = 'red';
    }

    handleMouseOut(event) {
        event.currentTarget.style.backgroundColor = '';
        event.currentTarget.style.color = '';
    }

    handleNoCancel(){
        this.showcancelModal = false;
    }
    handlecancel(){
      this.reloadPage();
        this.showcancelModal = true;
    }
    handleYesCancel(){
        this.showcancelModal = false;
        this.showchangeAdmin = false;
        this.showBasicinfo = true;
    }

    
    handlenext(){
        if(this.agreeChange && this.selectedUserId != ''){
          
            window.scrollTo(0,0);
            this.showstep2 = true;
            this.showstep1 = false;
            // oldnewadmin({oldAdmin: this.contactId ,newAdmin: this.selectedUserId})
            // .then(result =>
            //     {console.log(result);}
            // )
        }if(!this.agreeChange) {
            if(this.selectedUserId == ''){
                const toastEvent = new ShowToastEvent({
                    title: "エラー",
                    message: "please select the new admin user",
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            }else{
                this.showagreeModal = true;
            }
        }if(this.selectedUserId == '' && this.agreeChange){
            if(this.selectedUserId == ''){
                const toastEvent = new ShowToastEvent({
                    title: "エラー",
                    message: "please select the new admin user",
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            }
        }
        console.log("inside next button")
    }

    handleagreeyes(){
        this.showagreeModal = false;
        this.showchangeAdmin = true;
    }
    handleCheckboxChange(event) {
        let checkName = event.target.name;
        let isChecked = event.target.checked;
        if (checkName == "agreechange") {
          this.agreeChange = isChecked;
        } 
        console.log(this.agreeChange);
    }
    handleprev(){
      window.scrollTo(0,0);
        this.showstep1 = true;
        this.agreeChange = false;
        this.showstep2 = false;
    }
    handlenext2(){
      window.scrollTo(0,0);
        this.showstep2 = false;
        this.showstep3 = true;
        console.log("con id and selected user",this.contactId,this.selectedUserId)
        oldnewadmin({oldAdmin: this.contactId ,newAdmin: this.selectedUserId})
            .then(result =>
                {console.log(result);}
            )
    }
    handlelastbutton(){
      this.showchangeAdmin = false;
        this.showstep3 = false;
        this.reloadPage();
        this.showBasicinfo = true;
    }

    checkManagerUser() {
        checkManagerUser()
          .then((result) => {
            console.log("checkManagerUser result: ", result);
           this.showcanceledit = result;
          })
          .catch((error) => {
            this.errors = JSON.stringify(error);
            console.log("checkManagerUser errors:" + JSON.stringify(error));
          });
      }

      handleEdit(){
        this.close();
        this.showeditscreen = true;
        this.refreshTokenInt = ++this.refreshTokenInt;
        this.showBasicinfo = false;
      }

      handleInputChange(event) {
        const field = event.target.dataset.field;
    if (field) {
      let value = event.target.value;

      // Original value for display purposes
      let displayValue = value;
      
      // Convert hours to milliseconds for specific fields when storing
      if (field === "平日s" || field === "平日e" || field === "土日祝s" || field === "土日祝e") {
          value = parseFloat(value) * 60 * 60 * 1000; // hours to milliseconds
          if (isNaN(value)) {
              console.error("Invalid value for field:", field);
              return;
          }
      }

      switch (field) {
          case "姓":
              this.InputLastName = displayValue;
              this.contactClassLastName = this.InputLastName ? "" : "invalid-input";
              break;
          case "名":
              this.InputFirstName = displayValue;
              this.contactClassFirstName = this.InputFirstName ? "" : "invalid-input";
              break;
          case "姓（フリガナ）":
              this.InputLKanaName = displayValue;
              this.contactClassLKanaName = this.InputLKanaName ? "" : "invalid-input";
              break;
          case "名（フリガナ）":
              this.InputFKanaName = displayValue;
              this.contactClassFKanaName = this.InputFKanaName ? "" : "invalid-input";
              break;
          case "部署":
              this.InputDepartment = displayValue;
              break;
          case "役職":
              this.InputPost = displayValue;
              break;
          case "社員番号":
              this.InputEmpCode = displayValue;
              break;
          case "メールアドレス":
              this.InputEmail = displayValue;
              this.contactClassEmail = this.InputEmail ? "" : "invalid-input";
              break;
          case "電話番号":
              const onlyNumber = /^[0-9]*$/;
              let isOk = displayValue.length > 0 && onlyNumber.test(displayValue);
              this.InputTelephone = displayValue;
              this.contactClassTelephone = isOk ? "" : "invalid-input";
              break;
          case "携帯番号":
              const onlyNumberCell = /^[0-9]*$/;
              isOk = displayValue.length > 0 && onlyNumberCell.test(displayValue);
              this.InputCellPhone = displayValue;
              this.contactClassCellPhone = isOk ? "" : "invalid-input";
              break;
          case "平日s":
              this.workdayStart = displayValue;  // Store display value
              break;
          case "平日e":
              this.workdayEnd = displayValue;  // Store display value
              break;
          case "土日祝s":
              this.holidayStart = displayValue;  // Store display value
              break;
          case "土日祝e":
              this.holidayEnd = displayValue;  // Store display value
              break;
          default:
              console.warn("Unhandled field:", field);
      }

      // Ensure formData is an object and update it
      if (!this.formData) {
          this.formData = {};
      }
      this.formData[field] = value;  // Store converted value
      console.log("form data", JSON.stringify(this.formData));
  }
        // const field = event.target.dataset.field;
        // if (field) {
        //   let value = event.target.value;
        //   if (field === "平日s" || field === "平日e" || field === "土日祝s" || field === "土日祝e") {
        //     value = parseFloat(value) * 60 * 60 * 1000; // hours to milliseconds
        // }
        //   if (field == "姓") {
        //       this.InputLastName = event.target.value;
        //       this.contactClassLastName = this.InputLastName ? "" : "invalid-input";
        //     } else if (field == "名") {
        //       this.InputFirstName = event.target.value;
        //       this.contactClassFirstName = this.InputFirstName
        //         ? ""
        //         : "invalid-input";
        //     } else if (field == "姓（フリガナ）") {
        //       this.InputLKanaName = event.target.value;
        //       this.contactClassLKanaName = this.InputLKanaName
        //         ? ""
        //         : "invalid-input";
        //     } else if (field == "名（フリガナ）") {
        //       this.InputFKanaName = event.target.value;
        //       this.contactClassFKanaName = this.InputFKanaName
        //         ? ""
        //         : "invalid-input";}
        //     } else if (field == "部署") {
        //       this.InputDepartment = event.target.value;
        //     } else if (field == "役職") {
        //       this.InputPost = event.target.value;
        //     } else if (field == "社員番号") {
        //       this.InputEmpCode = event.target.value;
        //     } else if (field == "メールアドレス") {
        //       this.InputEmail = event.target.value;
        //       this.contactClassEmail = this.InputEmail ? "" : "invalid-input";
        //     } else if (field == "電話番号") {
        //       const onlyNumber = /^[0-9]*$/;
        //       const input = event.target;
        //       let isOk =
        //         input.value.length > 0 && onlyNumber.test(input.value)
        //           ? true
        //           : false;
        //       this.InputTelephone = input.value;
    
        //       this.contactClassTelephone = isOk == true ? "" : "invalid-input";
        //     } else if (field == "携帯番号") {
        //       const onlyNumber = /^[0-9]*$/;
        //       const input = event.target;
        //       let isOk =
        //         input.value.length > 0 && onlyNumber.test(input.value)
        //           ? true
        //           : false;
        //     this.InputCellPhone = input.value;
    
        //       this.contactClassCellPhone = isOk == true ? "" : "invalid-input";
        //     }else if(field == "平日s"){
        //       this.workdayStart = value;
        //     }else if(field == "平日e"){
        //       this.workdayEnd = value;
        //     }else if(field == "土日祝s"){
        //       this.holidayStart = value;
        //     }else if(field == "土日祝e"){
        //       this.holidayEnd = value;
        //     }
    
        //     this.formData[field] = event.target.value;
        //     console.log("form data",JSON.stringify(this.formData));
          }
      
        handlebranChange(event) {
            event.stopPropagation();
            this.showlist = !this.showlist;
            if (this.branchoptions.length == 0) {
                this.showlist = false;
            }
        }
        handleInsideClick(event) {
            event.stopPropagation();
        }
        handleSearch(event) {
            this.searchTerm = event.target.value.toLowerCase();
          }
        get filteredbranch() {
            if (!this.searchTerm) {
              return this.branchoptions;
            }
            return this.branchoptions.filter((veh) => {
              return veh.label.toLowerCase().includes(this.searchTerm);
            });
        }

        handleBranchSelect(event) {
            if (this.branchoptions.length == 1) {
              this.showlist = false;
            }
            this.selectbranchId = event.currentTarget.dataset.id;
            this.handlebranchChange();
          }

          handleDeleteBranch(event) {
            const vehicleId = event.currentTarget.dataset.id;
            const deletedVehicleFromVehicleArray = this.branch.find(
              (veh) => veh.Id === vehicleId
            );
            if (deletedVehicleFromVehicleArray) {
              this.branchoptions = [
                ...this.branchoptions,
                {
                  label: deletedVehicleFromVehicleArray.Name,
                  value: deletedVehicleFromVehicleArray.Id
                }
              ];
           }
        
            const deletedVehicleFromMoreVehiclesArray = this.branchfromjunction.find(
              (veh) => veh.Id === vehicleId
            );
            if (
              deletedVehicleFromMoreVehiclesArray &&
              !deletedVehicleFromVehicleArray
            ) {
              this.branchoptions = [
                ...this.branchoptions,
                {
                  label: deletedVehicleFromMoreVehiclesArray.Name,
                  value: deletedVehicleFromMoreVehiclesArray.Id
                }
              ];
            }
            
            this.deletedBranchIds.push(vehicleId);
            
            this.branch = this.branch.filter((veh) => veh.Id !== vehicleId);
           
            this.branchfromjunction = this.branchfromjunction.filter(
              (veh) => veh.Id !== vehicleId
            );
            this.selectbranchId = "";
          }

          handlebranchChange() {
            let selectedBranch = "";
            for (let i = 0; i < this.branchoptions.length; i++) {
              if (this.branchoptions[i].value === this.selectbranchId) {
                selectedBranch = this.branchoptions[i];
                this.branchoptions = this.branchoptions.filter(
                  (bran) => bran.value !== this.selectbranchId
                );
                break;
              }
            }
            if (selectedBranch) {
              this.branch.push({
                Id: selectedBranch.value,
                Name: selectedBranch.label
              });
              this.branchDataForClass.push(selectedBranch.label);
            }
            this.selectbranchId = null;
            if (this.branchoptions.length == 0) {
              this.showlist = false;
            }
          }
          handleOutsideClick = (event) => {
            const dataDropElement = this.template.querySelector(".dataDrop");
            const listsElement = this.template.querySelector(".lists");
        
            if (
              dataDropElement &&
              !dataDropElement.contains(event.target) &&
              listsElement &&
              !listsElement.contains(event.target)
            ) {
              this.showlist = false;
            }
          };

          renderedCallback() {
            if (!this.outsideClickHandlerAdded) {
              document.addEventListener("click", this.handleOutsideClick.bind(this));
              this.outsideClickHandlerAdded = true;
            }
          }
        
          disconnectedCallback() {
            document.removeEventListener("click", this.handleOutsideClick.bind(this));
          }
          branchdeleteAdd() {
            if (this.deletedBranchIds.length > 0) {
              branchContactDelete({
                contactId: this.contactId,
                branchesToDelete: this.deletedBranchIds
              });
            }
            if (this.branch.length > 0) {
              const branIdsToAdd = this.branch.map((vehicle) => vehicle.Id);
              branchContactAdd({
                contactId: this.contactId,
                branchesToAdd: branIdsToAdd
              });
            }
          }
  handleCanceledit(){
    this.showcancelModaledit = true;
  }
  handleNoCanceledit(){
    this.showcancelModaledit = false;
  }
  handleYesCanceledit(){
    this.reloadPage();
    window.scrollTo(0,0);
    this.showcancelModaledit = false;
    this.showeditscreen = false;
    this.showBasicinfo = true;
  }
  saveFormData(){
    let onlyNumber = /^[0-9]*$/;
    
    console.log("after 36000000000",this.formData);
    if (
      this.InputFirstName == "" ||
      this.InputLastName == "" ||
      this.InputFKanaName == "" ||
      this.InputLKanaName == "" ||
      this.InputEmail == "" ||
      (this.InputTelephone == "" && this.InputCellPhone == "")
    ) {
      this.handleError();
    } else if (
      this.InputTelephone == "" &&
      !onlyNumber.test(this.InputCellPhone)
    ) {
      this.contactClassCellPhone = "invalid-input";
      this.handleValidationError();
    } else if (
      !onlyNumber.test(this.InputTelephone) &&
      this.InputCellPhone == ""
    ) {
      this.contactClassTelephone = "invalid-input";
      this.handleValidationError();
    } else if (
      this.InputTelephone != "" &&
      this.InputCellPhone != "" &&
      (!onlyNumber.test(this.InputTelephone) ||
        !onlyNumber.test(this.InputCellPhone))
    ) {
      this.contactClassTelephone = "invalid-input";
      this.contactClassCellPhone = "invalid-input";
      this.handleValidationError();
    }else {
      this.formDataArray = [];
      this.formData["ContactId"] = this.contactId;
      this.formDataArray.push(this.formData);
      let filteredData = JSON.stringify(this.formDataArray);

      const asyncFunction = async () => {
        try {
          this.showeditscreen = false;
          this.isLoading = true;
          console.log("loading",this.isLoading);
          this.showBasicinfo = true;
          this.open();
          
          
          window.scrollTo(0,0);
          await this.updateUser(filteredData);
          await this.branchdeleteAdd();

          this.refreshTokenInt = ++this.refreshTokenInt;
          this.refreshTokenInt2 = ++this.refreshTokenInt2;

          this.branch = [];
          console.log(
            "refresh1 ,refresh2, selectedUserId in save form",
            this.refreshTokenInt,
            this.refreshTokenInt2,
            this.contactId
          );
          setTimeout(async () => {
            // this.handleSuccess();
            this.showModalAndRefresh();
            // this.showModalAndRefresh();
            this.refreshTokenInt = ++this.refreshTokenInt;
            this.refreshTokenInt2 = ++this.refreshTokenInt2;
            // this.showUserList = false;
            this.isLoading = false;
            console.log("loading",this.isLoading);
            // this.getUserAllServicesList(this.selectedContactUserId);
          }, 2000);

        } catch (error) {
          console.error("Error updating user:", error);
          this.handleValidationError();
        }
      };

      asyncFunction();
    }
  }

  handleError() {
    const evt = new ShowToastEvent({
      title: "エラー",
      message: "必須項目を入力してください。",
      variant: "Error"
    });
    this.dispatchEvent(evt);
  }
  handleValidationError() {
    const evt = new ShowToastEvent({
      title: "エラー",
      message: " 正しい値を入力してください。",
      variant: "Error"
    });
    this.dispatchEvent(evt);
  }
  handleSuccess() {
    const evt = new ShowToastEvent({
      title: "完了",
      message: "情報が正常に更新されました。",
      variant: "Success"
    });
    this.dispatchEvent(evt);
  }
  updateUser(formDataArray) {
    // Return the promise from updateUser function
    return new Promise((resolve, reject) => {
      const BranchIdsToAdd = this.branch.map((bran) => bran.Id);
      console.log("BRANCH UPDATED",BranchIdsToAdd)
      updateUser({ uiFieldJson: formDataArray, branches: BranchIdsToAdd })
        .then((result) => {
          resolve(result); // Resolve the promise on success
        })
        .catch((error) => {
          console.error("update User error:" + JSON.stringify(error));
          reject(error); // Reject the promise on error
        });
    });
  }
  showModalAndRefresh() {
    this.showModal = true;
    setTimeout(() => {
        this.showModal = false;
        this.reloadPage();
    }, 2000);
}
reloadPage() {
  location.reload();
}
}