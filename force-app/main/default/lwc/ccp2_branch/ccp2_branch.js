import { LightningElement, wire, track } from 'lwc';
import BranchList from '@salesforce/apex/CCP2_userData.BranchList';
import BranchVehicleCount from '@salesforce/apex/CCP2_branchController.getBranchList';
import { NavigationMixin } from 'lightning/navigation';
import Vehicle_StaticResource from '@salesforce/resourceUrl/CCP_StaticResource_Vehicle';

import CCP2_Branch from '@salesforce/label/c.CCP2_Branch';
import CCP2_BranchList from '@salesforce/label/c.CCP2_BranchList';
import CCP2_AffiliatedVehicles from '@salesforce/label/c.CCP2_AffiliatedVehicles';
import CCP2_CreateBranch from '@salesforce/label/c.CCP2_CreateBranch';
import CCP2_TOPPage from '@salesforce/label/c.CCP2_TOPPage';
import CCP2_BranchManagement from '@salesforce/label/c.CCP2_BranchManagement';

const BACKGROUND_IMAGE_PC = Vehicle_StaticResource + '/CCP_StaticResource_Vehicle/images/Main_Background.png';


export default class Ccp2Branch extends NavigationMixin(LightningElement) {


    labels = {
        CCP2_Branch,
        CCP2_BranchList,
        CCP2_AffiliatedVehicles,
        CCP2_CreateBranch,
        CCP2_TOPPage,
        CCP2_BranchManagement
    };


    backgroundImagePC = BACKGROUND_IMAGE_PC;

    @track branches;
    @track branchData = [];
    @track selectedBranch = false;
    @track showBranchDetail = false;

    @track branch = true;
    @track branchId;
    @track branchMain = true;
    @track addBranch = false;
    @track branchA = false; 
    
    @ track vehicleCount = [];
    
    branchesName;

    @wire(BranchVehicleCount)
    wiredBranchesNo({ error, data }) {
        if (data) {
            this.branchData = Object.values(data);
            console.log('Count', data);
            console.log(JSON.stringify(this.branchData));
        } else if (error) {
            console.error('Error loading branches:', error);
        }
    }

    
    handleBranchClick(event) {
        const branchId = event.target.dataset.idd;
        console.log("branch id", branchId); // Log the branchId to verify it's correct
        this.selectedBranch = this.branches.find(branch => branch.Id === branchId);
        this.selectedBranch = true;
        // this.branch = false;
    }
    connectedCallback(){
        const link = document.createElement('link');
        link.href = 'https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@100..900&display=swap';
        link.rel = 'stylesheet';
        document.head.appendChild(link);
    }

    handleclick2(event){
        this.branchId = event.currentTarget.dataset.id;
        console.log("branchId",this.branchId);
        this.branchA = true;
        window.scrollTo(0, 0);
        this.branch = false;
    }
    
    navigateToNewBranch() {
        this.addBranch = true; // Show add branch form
        this.branch = false; // Hide branch list
        console.log("working");
    }

    //@future reference

    // navigateToNewBranch() {
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__objectPage',
    //         attributes: {
    //             objectApiName: 'CCP2_Branch__c',
    //             actionName: 'new'
    //         }
    //     });
    // }
    goToMain(){
        let baseUrl = window.location.href;
        if(baseUrl.indexOf("/s/") !== -1) {
        let addBranchUrl = baseUrl.split("/s/")[0] + "/s/";;
        window.location.href = addBranchUrl;
    }
    }
    goToCreateBranch(){
        let baseUrl = window.location.href;
            if(baseUrl.indexOf("/s/") !== -1) {
            let addBranchUrl = baseUrl.split("/s/")[0] + "/s/createbranch";
            window.location.href = addBranchUrl;
        }
    }
}