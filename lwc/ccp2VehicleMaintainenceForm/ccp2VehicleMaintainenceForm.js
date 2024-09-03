import { LightningElement,api, track, wire } from 'lwc';
import CloseButtonImg from '@salesforce/resourceUrl/CloseButton';
import VehicleMaintainceStep1Img from '@salesforce/resourceUrl/VehicleMaintainceStep1';
import VehicleMaintainceStep2Img from '@salesforce/resourceUrl/VehicleMaintainceStep2';
import VehicleMaintainceStep3Img from '@salesforce/resourceUrl/VehicleMaintainceStep3';
import VehicleMaintainceStep4Img from '@salesforce/resourceUrl/VehicleMaintainceStep4';
import getVehicleById from "@salesforce/apex/CCP2_VehicleDetailController.getVehicleById";



import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import dropdownImg from '@salesforce/resourceUrl/dropdown';



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
     outsideClickHandlerAdded = false;

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
VehicleMaintainceStep1 = VehicleMaintainceStep1Img;
VehicleMaintainceStep2 = VehicleMaintainceStep2Img;
VehicleMaintainceStep3 = VehicleMaintainceStep3Img;
VehicleMaintainceStep4 = VehicleMaintainceStep4Img;
dropdown = dropdownImg;


   connectedCallback(){
    console.log(this.vehId);
    // document.addEventListener('click', this.handleOutsideClick);
    this.template.host.style.setProperty(
        "--dropdown-icon",
        `url(${this.dropdown})`
      );
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
       { label: '三菱ふそう工場' },
       { label: '自社工場' },
       { label: '上記以外' },
    
   ];

   // Toggle dropdown visibility
   handlePlaceofImplementationChange(event) {
    event.stopPropagation();
       this.showlistPlaceOfImplementation = !this.showlistPlaceOfImplementation;
   }

   // Handle picklist item selection
   handlePickListChange(event) {
       const selectedValue = event.target.dataset.idd;
       this.selectedPicklistPlaceofImplementation = selectedValue;
       this.showlistPlaceOfImplementation = false; // Hide dropdown after selection
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
    { label: '3ヶ月点検' },
    { label: '6ヶ月点検' },
    { label: '12ヶ月点検' },
    { label: '車検' },
    { label: '一般整備' }
 
];

// Toggle dropdown visibility
handleScheduleTypeChange(event) {
    event.stopPropagation();
    this.showlistScheduleType = !this.showlistScheduleType;
}

// Handle picklist item selection
handlePickListChange2(event) {
    const selectedValue = event.target.dataset.idd;
    this.selectedPicklistScheduleType = selectedValue;
    this.showlistScheduleType = false; // Hide dropdown after selection
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

GoToStep2(){
    if (!this.selectedPicklistPlaceofImplementation) {
        this.showToast('Error', 'Please select a Place of Implementation', 'error');
    }
    if (!this.selectedPicklistScheduleType) {
        this.showToast('Error', 'Please select a schedule type', 'error');

    }
else {
        this.step2 = true;
        this.Step1 = false;
    }
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

    

  }