import { LightningElement,api, track, wire } from 'lwc';
import CloseButtonImg from '@salesforce/resourceUrl/CloseButton';
import Vehicle_StaticResource from '@salesforce/resourceUrl/CCP2_Resources';
import getVehicleById from "@salesforce/apex/CCP2_VehicleDetailController.getVehicleById";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const  step1img = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/vehStep1.png';
const  step2img = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/vehStep2.png';
const  step3img = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/vehStep3.png';
const  step4img = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/vehStep4.png';
const  dropdownImg = Vehicle_StaticResource + '/CCP2_Resources/Common/arrow_under.png';
const  poster1 = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/Poster-Image-1.png';
const  poster2 = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/Poster-Image-2.png';
const component1Image = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/Comp1.png';
const component2Image = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/Comp2.png';
const component3Image = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/Comp3.png';
const component4Image = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/Comp4.png';
const component5Image = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/Comp5.png';
const component6Image = Vehicle_StaticResource + '/CCP2_Resources/Vehicle/Comp6.png';

export default class Ccp2VehicleMaintainenceForm extends LightningElement {
    @api vehId;
    @track showlistPlaceOfImplementation = false;
    @track selectedPicklistPlaceofImplementation = '';
    @track showlistScheduleType = false;
    @track selectedPicklistScheduleType= '';
    @track showCancelModal = false;
    @track mainTemplate = true;
    @track Step1 = true;
    @track step2 = false;
     @track step3 = false;
     @track step4 = false;
     @track maintainencedetail = true;
     outsideClickHandlerAdded = false;
     VehicleMaintainceStep1 = step1img;
     VehicleMaintainceStep2 = step2img;
     VehicleMaintainceStep3 = step3img;
     VehicleMaintainceStep4 = step4img;
     dropdown = dropdownImg;
     poster1 = poster1;
     poster2 = poster2;
     FusoShop = "https://login.b2b-int.daimlertruck.com/corptbb2cstaging.onmicrosoft.com/oauth2/v2.0/authorize?p=B2C_1A_signup_signin&client_id=4d21e801-db95-498f-8cc5-1363af53d834&nonce=defaultNonce&redirect_uri=https://jsapps.c3sf1r8zlh-daimlertr2-s1-public.model-t.cc.commerce.ondemand.com/mftbc/ja&scope=openid&response_type=code&ui_locales=ja";
    
     branchError = false;
     branchErrorText;
     @track showerrorbranch = false;
     @track showerrorbranchNull = false;
     @track showerrorScheduleType = false;
     @track buttonActive = false;
     @track showPoster1 = false;
     @track showPoster2 = false;

     vehicleImages = [
        { name: 'Component1', imageUrl: component1Image},
        { name: 'Component2', imageUrl: component2Image},
        { name: 'Component3', imageUrl: component3Image},
        { name: 'Component4', imageUrl: component4Image},
        { name: 'Component5', imageUrl: component5Image},
        { name: 'Component6', imageUrl: component6Image}
     ];

     @track vehicleByIdData = {
        
        id: 10,
        name: "-",
        type: "-",
      
        mileage: "-",
        vehicleNumber: "-",

        vehicleInspectionCertificateIssueDate: "-",
   
        vehicleWeigth: "-",
        VehicleInspectionCertificateExpirationDate: "-",
        registrationNumber: "-"
      };
    


    CloseButton = CloseButtonImg;



   connectedCallback(){
    const link = document.createElement('link');
    link.href = 'https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@100..900&display=swap';
    link.rel = 'stylesheet';
    document.head.appendChild(link);
    // document.addEventListener('click', this.handleOutsideClick);
    this.template.host.style.setProperty(
        "--dropdown-icon",
        `url(${this.dropdown})`
      );
      this.template.host.style.setProperty(
        "--poster-background",
        `url(${this.poster2})`
      );
      this.shouldShowListNew();
   }

   goback(){
    this.maintainencedetail = false;
    window.scrollTo(0,0);
   }

   renderedCallback() {
    // Attach click event to close dropdown on outside click
    if (!this.handleOutsideClickBound) {
        this.handleOutsideClickBound = this.handleOutsideClick.bind(this);
        document.addEventListener('click', this.handleOutsideClickBound);
    }
}

   disconnectedCallback() {
    if (this.handleOutsideClickBound) {
        document.removeEventListener('click', this.handleOutsideClickBound);
        this.handleOutsideClickBound = null;
    }
}
 

   // Hardcoded picklist values
   PlaceOfImplementationOptions = [
       { label: '自社の工場' },
       { label: 'その他（民間の工場など）' }, 
 
    
   ];

   // Toggle dropdown visibility
   handlePlaceofImplementationChange(event) {
    this.showerrorbranchNull = false; // Clear error when dropdown is opened

    event.stopPropagation();

       this.showlistPlaceOfImplementation = !this.showlistPlaceOfImplementation;
       this.showlistScheduleType = false;
   }

   // Handle picklist item selection
   handlePickListChange(event) {
       const selectedValue = event.target.dataset.idd;
       this.selectedPicklistPlaceofImplementation = selectedValue;
       console.log("val2",this.selectedPicklistPlaceofImplementation);
       this.showlistPlaceOfImplementation = false;
       console.log("a213");
       this.shouldShowListNew();
   }

   // Handle clicks outside the dropdown to close it
   handleInsideClick(event) {
       // Prevent closing if clicking inside the dropdown
    //    if (event.target.closest('.listPlaceOfImplemenation')) return;
    //    this.showlistPlaceOfImplementation = false;
    event.stopPropagation();
   }


   // Hardcoded picklist values
   ScheduleTypeOptions = [
    { label: '車検' },
    { label: '3ヶ月点検' },
    { label: '6ヶ月点検' },
    { label: '12ヶ月点検' },
    { label: '一般整備' }
 
];

// Toggle dropdown visibility
handleScheduleTypeChange(event) {
    this.showerrorScheduleType = false; // Clear error when dropdown is opened

    event.stopPropagation();
    this.showlistScheduleType = !this.showlistScheduleType;
    this.showlistPlaceOfImplementation = false;
}
shouldShowListNew() {
    // console.log("working1");
    // console.log("val1a",this.selectedPicklistPlaceofImplementation);
    // console.log("val2a",this.selectedPicklistScheduleType);
    if (this.selectedPicklistScheduleType && this.selectedPicklistPlaceofImplementation) {
        this.buttonActive = true;
        // console.log("selected both");
    } else {
        this.buttonActive = false;
        // console.log("pending 1");
    }
    // console.log("btn active",this.buttonActive);
    return this.buttonActive;

}

// Handle picklist item selection
handlePickListChange2(event) {
    const selectedValue = event.target.dataset.idd;
    this.selectedPicklistScheduleType = selectedValue;
    console.log("val",this.selectedPicklistScheduleType);
    this.showlistScheduleType = false; // Hide dropdown after selection
    console.log("a1");
    this.shouldShowListNew();
}

// Handle clicks outside the dropdown to close it
handleInsideClick(event) {
    // Prevent closing if clicking inside the dropdown
    // if (event.target.closest('.listScheduleType')) return;
    // this.showlistScheduleType = false;
    event.stopPropagation();
}
showCancelModalFunction(){
    this.showCancelModal = true;
}
handleNo(){
    this.mainTemplate = true;
    this.showCancelModal = false;


}

// GoToStep2(){
//     const branchInput = this.template.querySelector('input[name="PlaceOfImplementation"]');
//     const scheduleTypeInput = this.template.querySelector('input[name="ScheduleType"]');
//     this.showerrorScheduleType = false;
//     this.showerrorbranchNull = false;
   
// if (!scheduleTypeInput.value && !branchInput.value ) {
//         branchInput.classList.add('invalid-input'); // Add error styling

//     scheduleTypeInput.classList.add('invalid-input'); // Add error styling
//       this.showerrorScheduleType = true;  // Show error message for schedule type input
//       this.showerrorbranchNull = true; 
//           window.scrollTo(0, 0);  // Scroll to the top if needed
//     isValid = false;  // Set isValid to false
// } else {
//     branchInput.classList.remove('invalid-input');  // Remove error styling if valid
//     this.showerrorbranchNull = false;  // Hide error message for branch input
//     scheduleTypeInput.classList.remove('invalid-input');  // Remove error styling if valid
//     this.showerrorScheduleType = false;  // Hide error message for schedule type input
// }
   
//     // Proceed to step 2 if there are no errors
//     this.step2 = true;
//     this.Step1 = false;
// }
GoToStep2() {
    this.step2 = true;
    this.Step1 = false;
}

GoBackToStep1(){
    this.Step1 = true;
    this.step2 = false;
}
showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant // 'success', 'error', 'info', 'warning'
    });
    this.dispatchEvent(event);
}
GoToStep3(){
    this.step3= true;
    this.step2 = false;
}
GoBackToStep2(){
    this.step3 = false;
    this.step2 = true;
    this.step1 = false;
}
GoToStep4(){
    this.step3 = false;
    this.step2 = false;
    this.step1 = false;
    if(this.selectedPicklistScheduleType === '一般整備'){
        this.showPoster1 = true;
    }else{
        this.showPoster2 = true;
    }
    this.step4 = true;
}

@wire(getVehicleById, { vehicleId: '$vehId' })
    handleData({ data, error }) {
        if (data) {
            console.log('Fetching vehicle by Id:', this.vehId);
            console.log('Vehicle data:', data);

            // Assuming `data` is a single record and not an array
            const vehicle = data[0] || {};

            this.vehicleByIdData = {
                id: vehicle.Id || '-',
                name: vehicle.Vehicle_Name__c || '-',
                type: vehicle.Vehicle_Type__c || '-',
              
                typeOfFuel: vehicle.Fuel_Type__c || '-',
                mileage: vehicle.Mileage__c || '-',
               
                vehicleNumber: vehicle.Vehicle_Number__c || '-',
                VehicleInspectionCertificateExpirationDate: vehicle.Vehicle_Expiration_Date__c || '-',           
                vehicleInspectionCertificateIssueDate: vehicle.vehicleInspectionCertificateIssueDate || '-',
                registrationNumber: vehicle.Registration_Number__c || '-'
            };

            console.log('Updated vehicle data:', this.vehicleByIdData);
        } else if (error) {
            console.error('Error fetching vehicle data:', error);
        }
    }
 
    handleOutsideClick(event) {
        const isClickInside = this.template.querySelector('.Combox-input-wr').contains(event.target);
        if (!isClickInside) {
            this.showlistPlaceOfImplementation = false;
            this.showlistScheduleType = false;
        }
    }
 

    // handleOutsideClick = (event) => {
    //     const dataDropElement = this.template.querySelector('.InputsScheduleType');
    //     const listsElement = this.template.querySelector('.listScheduleType');

    //     if (
    //         dataDropElement &&
    //         !dataDropElement.contains(event.target) &&
    //         listsElement &&
    //         !listsElement.contains(event.target)
    //     ) {
    //         this.showlistScheduleType = false;
    //         this.showlistPlaceOfImplementation = false;
    //         console.log("Clicked outside");
    //     }
    // };

    // handleInsideClick(event) {
    //     event.stopPropagation();
    // }
   
    // renderedCallback() {
    //     if (!this.outsideClickHandlerAdded) {
    //         document.addEventListener('click', this.handleOutsideClick);
    //         this.outsideClickHandlerAdded = true;
    //     }
    // }

    // disconnectedCallback() {
    //     document.removeEventListener('click', this.handleOutsideClick);
    // }
    handleYes(){
        this.showCancelModal = false;
      
    }
    openlink(){
        window.open(this.FusoShop, '_blank');
    }

  }