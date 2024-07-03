import { LightningElement, wire, track, api } from 'lwc';
import getVehicleById from '@salesforce/apex/CCP2_VehicleDetailController.getVehicleById'
export default class Ccp2_vehicleDetails extends LightningElement {
    @track vehicleByIdLoader = true;
    @track vehicleByIdData = {
        id: 100,
        vehicleBrand: 100,
        type: 100,
        registerYear: 100,
        mileage: 100,
        vinNumber: 100,
        carFormat: 100,
        lastDate: 100,
        bodymaker: 100,
        bodyShape: 100,
        initialDate: 100,
        initialRegistrationDate: 100
    };
    @wire(getVehicleById, { vehicleId: "a0oIo000000POvCIAW" }) handledata({ data, error }) {
        if (data) {
            //   this.carModel = data.CarModel__c;
            //   this.finalUpdater = data.FinalUpdater__c;
            //   this.maker = data.Maker__c;
            //   this.lastUpdateDate = data.LastUpdateDate__c;
            //   this.name = data.Name;
            //   this.regDate = data.Reg_date__c;
            //   this.updater = data.Updater__c;
            //   this.maintenanceDate = data.Maintenance_date__c;
            //   this.brand = data.brand__c;
            //   this.TruckImg = data.Img__c;
            console.log('geting from vehicle by Id api: ', data);
            if (data.length != 0) {
                let obj = {
                    id: data[0].Id,
                    vehicleBrand: data[0].vehicleBrandName__c,
                    type: data[0].type__c,
                    registerYear: data[0].Registration_Year__c,
                    mileage: data[0].mileage__c,
                    vinNumber: data[0].chassisNumberVIN__c,
                    carFormat: data[0].CarModelFormatName__c,
                    lastDate: data[0].lastArrivalDateTime__c,
                    bodymaker: data[0].BodyMakerNo__c,
                    bodyShape: data[0].bodyShape__c,
                    initialDate: data[0].DatefronInitialRegistrationDate__c,
                    initialRegistrationDate: data[0].initialRegistrationOfJapaneseCalender__c
                }
                console.log('object geting from vehicle by Id api: ', obj);
                this.vehicleByIdData = obj;
                this.vehicleByIdLoader = false;
            }
        } else if (error) {
            // handle error
            console.error('geting from vehicle by Id api: ', error)
        }
    }

    dothis() {
        console.log('dothis function called');
    }
}