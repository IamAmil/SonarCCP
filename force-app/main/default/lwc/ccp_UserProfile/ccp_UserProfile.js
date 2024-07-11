/*
 * @Author: Huanghao Tu
 * @Date: 2022-10-12 12:48:43
 * @LastEditTime: 2023-01-03 09:29:07
 * @Description: 基本情報
 */
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Profile_StaticResource from '@salesforce/resourceUrl/CCP_StaticResource_Vehicle';
import getContactData from '@salesforce/apex/CCP_UserProfileCtrl.getContactData';
import updateContactData from '@salesforce/apex/CCP_UserProfileCtrl.updateContactData';
import userTypeJudgment from '@salesforce/apex/CCP_UserProfileCtrl.userTypeJudgment';
import permissionDBCheck from '@salesforce/apex/CCP_UserUtil.permissionDBCheck';
import permissionEICheck from '@salesforce/apex/CCP_UserUtil.permissionEICheck';
import userFDPCheck from '@salesforce/apex/CCP_UserUtil.userFDPCheck';
import getBaseInfoByUserId from '@salesforce/apex/CCP_HomeCtrl.getBaseInfoByUserId';
import Id from '@salesforce/user/Id';

const BACKGROUND_IMAGE_PC = Profile_StaticResource + '/CCP_StaticResource_Vehicle/images/Main_Background.png';
const BACKGROUND_IMAGE_MOBILE = Profile_StaticResource + '/CCP_StaticResource_AddUser/images/register_img_hero.png';
export default class Ccp_UserProfile extends LightningElement {
    backgroundImagePC = BACKGROUND_IMAGE_PC;
    backgroundImageMobile = BACKGROUND_IMAGE_MOBILE;
    contactData;
    workdayStart;
    workdayEnd;
    holidayStart;
    holidayEnd;
    // isNotReceiveByPhone;
    // isNotReceiveByPostcard;
    defaultDisplay;
    isLoading = false;
    updateSuccess = false;
    vehicleShow = false;
    isFDPShow = true;

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

    getContactData(){
        getContactData().then(data => {
            let contactData = [];
            if(data != null){
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
                    accountCode: accountData.siebelAccountCode__c,
                }];
                // the time field return the milliseconds so the time need divided by 3600000
                this.workdayStart = this.getTime(data.mostLikelyWeekdayStartTimesForAppoint__c);
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
                if(this.defaultDisplay.workdayStart != null){
                    this.template.querySelector('[name="workdayStart"]').selectedIndex = Number(this.defaultDisplay.workdayStart) + 1;
                } else {
                    this.template.querySelector('[name="workdayStart"]').selectedIndex = 0;
                }
                if(this.defaultDisplay.workdayEnd != null){
                    this.template.querySelector('[name="workdayEnd"]').selectedIndex = Number(this.defaultDisplay.workdayEnd) + 1;
                } else {
                    this.template.querySelector('[name="workdayEnd"]').selectedIndex = 0;
                }
                if(this.defaultDisplay.holidayStart != null){
                    this.template.querySelector('[name="holidayStart"]').selectedIndex = Number(this.defaultDisplay.holidayStart) + 1;
                } else {
                    this.template.querySelector('[name="holidayStart"]').selectedIndex = 0;
                }
                if(this.defaultDisplay.holidayEnd != null){
                    this.template.querySelector('[name="holidayEnd"]').selectedIndex = Number(this.defaultDisplay.holidayEnd) + 1;
                } else {
                    this.template.querySelector('[name="holidayEnd"]').selectedIndex = 0;
                }
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
}