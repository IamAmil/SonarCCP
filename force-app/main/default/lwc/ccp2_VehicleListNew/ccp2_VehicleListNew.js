import { LightningElement,track,wire } from 'lwc';
import getVehicleData from '@salesforce/apex/ccp2_vehicleList.getVehicleInfo';

export default class Ccp2_VehicleListNew extends LightningElement {
    vehicleData =[];
    CarModel =[];
    brandModel = [];
    offSetCount = 10;
    VehicleCount = 0;
    @track showVehicleList = true;
    @track showVehicleDetails = false;
    @track vehicleId;
    @track showVehicleModal = false;


@wire(getVehicleData,{CarModel: '$CarModel', brandModel: '$brandModel'})vehicledata({data,error}){

    if(data){
        this.vehicleData=data;
        this.VehicleCount = data.length;
        console.log("redata",this.vehicleData);
    }
    else if(error){
        console.log(error);
    }
}
handleClick(event) {
     this.vehicleId = event.currentTarget.dataset.id;
    console.log('Clicked Vehicle ID:', this.vehicleId);
    // this.dispatchEvent(new CustomEvent('vehicleclick', { detail: vehicleId }));
    this.showVehicleDetails = true;
    this.showVehicleList = false;
    
}
handleBack(){
    console.log("called");
    this.showVehicleList = true;
    this.showVehicleDetails = false;
}

showVehicleRegistration(){
 this.showVehicleModal = !this.showVehicleModal;
}
handleCloseModal(){
    this.showVehicleModal = false;
}
handlemoveModal(){
    this.showVehicleList = false;
}
}