import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import truckpic from '@salesforce/resourceUrl/CCP2_TruckProgress'
// import Vehicle_StaticResource from '@salesforce/resourceUrl/CCP_StaticResource_Vehicle';
// import getVehicleTypeClassMap from '@salesforce/apex/CCP_VehicleAddCtrl.getVehicleTypeClassMap';
// import getBrandOptions from '@salesforce/apex/CCP_VehicleAddCtrl.getBrandOptions';
// import checkCarPlatformNo from '@salesforce/apex/CCP_VehicleAddCtrl.checkCarPlatformNo';
// import createVehicleInfo from '@salesforce/apex/CCP_VehicleAddCtrl.createVehicleInfo';
// import getNumberOfAxesByCustomer from '@salesforce/apex/CCP_VehicleAddCtrl.getNumberOfAxesByCustomer';
// import userTypeJudgment from '@salesforce/apex/CCP_VehicleAddCtrl.userTypeJudgment';
// import sendEmailToAccountManager from '@salesforce/apex/CCP_VehicleAddCtrl.sendEmailToAccountManager';
// import sendNotificationToAccountManager from '@salesforce/apex/CCP_VehicleAddCtrl.sendNotificationToAccountManager';

export default class Ccp2vehiclemanualinput extends LightningElement {

    truckpic = truckpic;
    @track currentStep = 1;
    @track field1 = '';
    @track field2 = '';
    @track field3 = '';
    vehicleInputData = {
        
        vehicleNumber: '',
        regNum: '',
        regDate: '',
        firstregDate: '',
        chassisNum: '',
        vehicleType: '',
        use: '',
        carName: '',
        passCapacity: '',
        maxLoadCap: '',
        vehicleWeight:'',
        grossvehicleWeight: '',
        vehicleLength: '',
        vehicleWidth: '',
        vehicleHeight: '',
        carModel: '',
        mileage: '',
        displacement: '',
        engineModel: '',
        engineHorsePower: '',
        fuel: '',
        mission: '',
        owner: ''
    }


    get isStep1() {
        return this.currentStep === 1;
    }

    get isStep2() {
        return this.currentStep === 2;
    }


    get truckStyle() {
        return `left: calc(${(this.currentStep - 1) * 100}% - 20px);`;
    }

    get iconStyle() {
        return this.currentStep == 1 ? `red-utility-icon`  :  `grey-utility-icon`;
    }

    get dot(){
        return this.currentStep == 1 ? `dot` : `dot2`;
    }
    handleNext() {
        if (this.currentStep < 3) {
            this.currentStep += 1;
        }
    }

    handlePrevious() {
        if (this.currentStep > 1) {
            this.currentStep -= 1;
        }
    }

    handleFieldChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handleSubmit() {
        const fields = {
            field1: this.field1,
            field2: this.field2,
            regNum: this.regNum,
            vehicleNumber: this.vehicleNumber,
            chassisNum: this.chassisNum,
            use: this.use,
            carName: '',
            regDate: '',
            passCapacity: '',
            vehicleWidth: '',
            vehicleLength: '',
            carModel: '',
            engineHorsePower: '',
            mileage: '',
            fuel: '',
            displacement: ''
            
        };
        console.log('Form submitted with:', fields);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Form submitted successfully!',
                variant: 'success'
            })
        );

        this.currentStep = 1;
        this.field1 = '';
        this.field2 = '';
        // this.field3 = '';
    }

    handleFieldChange(event){
        let comboboxName = event.target.name;
        let comboboxValue = event.target.value;
        if(comboboxName == 'vehicleType'){
            this.vehicleInputData.className = comboboxValue;
            let type;
            this.typeOptions.forEach(item =>{
                if(item.value == comboboxValue){
                    type = item.label;
                }
            })
            this.vehicleInputData.type = type;
        } else if(comboboxName == 'vehicleNumber'){
            this.vehicleInputData.vehicleNumber = comboboxValue;
        }else if(comboboxName == 'regNum'){
            this.vehicleInputData.regNum = comboboxValue;
        } else if(comboboxName == 'regDate'){
            this.vehicleInputData.regDate = comboboxValue;
            comboboxValue = comboboxValue.replaceAll('-','/');
            this.regDate = comboboxValue;
        } else if(comboboxName == 'firstregDate'){
            this.vehicleInputData.firstregDate = comboboxValue;
            comboboxValue = comboboxValue.replaceAll('-','/');
            this.firstregDate = comboboxValue;
        } else if(comboboxName == 'chassisNum'){
            this.vehicleInputData.chassisNum = comboboxValue;
        } else if(comboboxName == 'use'){
            this.vehicleInputData.use = comboboxValue;
        } else if(comboboxName == 'carName'){
            this.vehicleInputData.carName = comboboxValue;
        } else if(comboboxName == 'carPlatformNo'){
            this.vehicleInputData.carPlatformNo = comboboxValue;
        } else if(comboboxName == 'passCapacity'){
            this.vehicleInputData.passCapacity = comboboxValue;
        } else if(comboboxName == 'maxLoadCap'){
            this.vehicleInputData.maxLoadCap = comboboxValue;
        } else if(comboboxName == 'vehicleWeight'){
            this.vehicleInputData.vehicleWeight = comboboxValue;
        }else if(comboboxName == 'grossvehicleWeight'){
            this.vehicleInputData.grossvehicleWeight = comboboxValue;
        }else if(comboboxName == 'vehicleLength'){
            this.vehicleInputData.vehicleLength = comboboxValue;
        }else if(comboboxName == 'vehicleWidth'){
            this.vehicleInputData.vehicleWidth = comboboxValue;
        }else if(comboboxName == 'vehicleHeight'){
            this.vehicleInputData.vehicleHeight = comboboxValue;
        }else if(comboboxName == 'carModel'){
            this.vehicleInputData.carModel = comboboxValue;
        }else if(comboboxName == 'mileage'){
            this.vehicleInputData.mileage = comboboxValue;
        }else if(comboboxName == 'displacement'){
            this.vehicleInputData.displacement = comboboxValue;
        }else if(comboboxName == 'engineModel'){
            this.vehicleInputData.engineModel = comboboxValue;
        }else if(comboboxName == 'engineHorsePower'){
            this.vehicleInputData.engineHorsePower = comboboxValue;
        }else if(comboboxName == 'fuel'){
            this.vehicleInputData.fuel = comboboxValue;
        }else if(comboboxName == 'mission'){
            this.vehicleInputData.mission = comboboxValue;
        }else if(comboboxName == 'owner'){
            this.vehicleInputData.owner = comboboxValue;
        } 
        this.nextButtonDisable();
    }

    nextButtonDisable(){
        if(this.vehicleInputData.className == null || this.vehicleInputData.brand == null || this.vehicleInputData.axesNumber == null ||
            this.vehicleInputData.registerNoLandNameRegionName == null || this.vehicleInputData.registerNoClassNumber == null ||
            this.vehicleInputData.registerNoKana == null || this.vehicleInputData.registerNoSerialNumber == null || 
            this.vehicleInputData.carPlatformNo == null || this.vehicleInputData.registerNoLandNameRegionName == '' || 
            this.vehicleInputData.registerNoClassNumber == '' || this.vehicleInputData.registerNoKana == '' || 
            this.vehicleInputData.registerNoSerialNumber == '' || this.vehicleInputData.carPlatformNo == '' || 
            this.vehicleInputData.initialRegistrationYear == null || this.vehicleInputData.initialRegistrationMonth == null || 
            this.vehicleInputData.vehicleInspectionExpiryDate == null || this.fileData == undefined){
            this.template.querySelector('[name="nextButton"]').className = 'primary_btn--m disabled';
        } else{
            this.template.querySelector('[name="nextButton"]').className = 'primary_btn--m';
        }
    }


    nextClick(){
        const onlyThreeNumber = /^[0-9]{3}$/;
        const onlyFourNumber = /^[0-9]{4}$/;
        const fullAngleNumbers = /[０-９]+$/;
        const fullAngleHiragana = /[ぁ-ん]/;
        const fullAngleKana = /[ァ-ヴ]/;
        const halfAngleKana = /[ｦ-ﾟ]/;
        const carPlatformNoFlag = /^[0-9A-Z-]+$/;
        const currentMonth = new Date().getMonth() + 1;
        const currentYear = new Date().getFullYear();
        this.isBack = false;
        let registerNoLandNameRegionNameError = false;
        let registerNoKanaError = false;
        let registerNoClassNumberError = false;
        let registerNoSerialNumberError = false;
        let registerNoLandNameRegionName = this.template.querySelector('[name="registerNoLandNameRegionName"]');
        let registerNoClassNumber = this.template.querySelector('[name="registerNoClassNumber"]');
        let registerNoKana = this.template.querySelector('[name="registerNoKana"]');
        let registerNoSerialNumber = this.template.querySelector('[name="registerNoSerialNumber"]');
        let carPlatformNo = this.template.querySelector('[name="carPlatformNo"]');
        let carPlatformNoErrorText = this.template.querySelector('[name="carPlatformNoErrorText"]');
        let initialRegistrationYear = this.template.querySelectorAll('lightning-combobox')[3];
        let initialRegistrationMonth = this.template.querySelectorAll('lightning-combobox')[4];

        if(fullAngleNumbers.test(registerNoLandNameRegionName.value) || fullAngleKana.test(registerNoLandNameRegionName.value) 
            || halfAngleKana.test(registerNoLandNameRegionName.value)){
            registerNoLandNameRegionName.className = 'form-input _error _register-number slds-form-element__control slds-input';
            registerNoLandNameRegionNameError = true;
        } else {
            registerNoLandNameRegionName.className = 'form-input _register-number slds-form-element__control slds-input';
            registerNoLandNameRegionNameError = false; 
        }

        if(!fullAngleHiragana.test(registerNoKana.value)){
            registerNoKana.className = 'form-input _error _register-number slds-form-element__control slds-input';
            registerNoKanaError = true;
        } else {
            registerNoKana.className = 'form-input _register-number slds-form-element__control slds-input';
            registerNoKanaError = false;
        }
        
        if(!onlyThreeNumber.test(registerNoClassNumber.value)){
            registerNoClassNumber.className = 'form-input _error _register-number slds-form-element__control slds-input';
            registerNoClassNumberError = true;
        } else{
            registerNoClassNumber.className = 'form-input _register-number slds-form-element__control slds-input';
            registerNoClassNumberError = false;
        }

        if(!onlyFourNumber.test(registerNoSerialNumber.value)){
            registerNoSerialNumber.className = 'form-input _error _register-number slds-form-element__control slds-input';
            registerNoSerialNumberError = true;
        } else{
            registerNoSerialNumber.className = 'form-input _register-number slds-form-element__control slds-input';
            registerNoSerialNumberError = false;
        }

        if(registerNoLandNameRegionNameError || registerNoKanaError || registerNoClassNumberError || registerNoSerialNumberError){
            this.registerNumberError = true;
        } else{
            this.registerNumberError = false;
        }

        if((!carPlatformNoFlag.test(carPlatformNo.value)) || carPlatformNo.value.length > 30){
            carPlatformNo.className = 'form-input _error slds-form-element__control slds-input';
            carPlatformNoErrorText.className = '_error';
            this.carPlatformNoError = true;
        } else{
            carPlatformNo.className = 'form-input slds-form-element__control slds-input';
            carPlatformNoErrorText.className = '';
            this.carPlatformNoError = false;
        }

        if(this.vehicleInputData.initialRegistrationYear == currentYear &&  this.vehicleInputData.initialRegistrationMonth > currentMonth){
            initialRegistrationMonth.className = 'select-date slds-form-element slds-has-error';
            initialRegistrationYear.className = 'select-date slds-form-element slds-has-error';
            this.initialRegistrationDateError = true;
        } else{
            initialRegistrationMonth.className = 'select-date slds-form-element';
            initialRegistrationYear.className = 'select-date slds-form-element';
            this.initialRegistrationDateError = false;
        }
        // if the page not error can turn to next section
        if(!this.registerNumberError && !this.carPlatformNoError && !this.initialRegistrationDateError && !this.isModalOpen){
            checkCarPlatformNo({carPlatformNo : carPlatformNo.value}).then(data => {
                if(data){
                    this.isModalOpen = true;
                } else{
                    this.isInputSection = false;
                    this.isCheckSection = true;
                    this.isCmpletionSection = false;
                    window.scrollTo(0, 0);
                }
            }).catch(error => {
                console.log('checkCarPlatformNo errors:' + JSON.stringify(error));    
            })
        } else{
            window.scrollTo(0, 0);
        }
    }

}