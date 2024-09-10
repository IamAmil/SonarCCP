import { LightningElement, wire, track } from 'lwc';
import BranchList from '@salesforce/apex/CCP2_userData.BranchList';
import BranchVehicleCount from '@salesforce/apex/CCP2_branchController.getBranchList';
import { NavigationMixin } from 'lightning/navigation';
import Vehicle_StaticResource from '@salesforce/resourceUrl/CCP2_Resources';
import CCP2_Branch from '@salesforce/label/c.CCP2_Branch';
import CCP2_BranchList from '@salesforce/label/c.CCP2_BranchList';
import CCP2_AffiliatedVehicles from '@salesforce/label/c.CCP2_AffiliatedVehicles';
import CCP2_CreateBranch from '@salesforce/label/c.CCP2_CreateBranch';
import CCP2_TOPPage from '@salesforce/label/c.CCP2_TOPPage';
import CCP2_BranchManagement from '@salesforce/label/c.CCP2_BranchManagement';

const BACKGROUND_IMAGE_PC = Vehicle_StaticResource + '/CCP2_Resources/Common/Main_Background.webp';

const RECORDS_PER_PAGE = 6; // Number of records to display per page

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
    @track branchloader = true;
    @track branch = true;
    @track branchId;
    @track branchMain = true;
    @track addBranch = false;
    @track branchA = false; 
    @track currentPage = 1;
    @track totalRecords = 50; // Sample total records
    @track pageNumbers = [];
    @track items = []; 
    @track isPageSelected = false;


    get isBranchesEmpty() {
        return this.branchData.length === 0;
    }

    // connectedCallback() {
    //     this.fetchBranchData();
    // }

    // fetchBranchData() {
    //     BranchVehicleCount()
    //         .then(result => {
    //             this.branchData = result;
    //             this.totalRecords = this.branchData.length;
    //             this.initializePageNumbers();
    //             this.fetchItems(this.currentPage);
    //         })
    //         .catch(error => {
    //             console.error('Error loading branches:', error);
    //         });
    // }

    @track paginatedBranchData = [];
    labels2 = {};

    connectedCallback() {
        this.loadI18nextLibrary().then(() => {
            this.loadLabels(); // Now you can safely load the labels after i18next is loaded
        }).catch((error) => {
            console.error("Error loading i18next library: ", error);
        });
        this.fetchBranchData();
        // this.initializePageNumbers();
        // this.fetchItems(this.currentPage);
        const link = document.createElement('link');
        link.href = 'https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@100..900&display=swap';
        link.rel = 'stylesheet';
        document.head.appendChild(link);
    }

    renderedCallback() {
        this.updatePageButtons();
    }

    loadI18nextLibrary() {
        return new Promise((resolve, reject) => {
            if (!window.i18next) {
                const script = document.createElement("script");
                script.src = i18nextStaticResource; // Load i18next from the static resource
                script.onload = () => {
                    resolve();
                };
                script.onerror = () => {
                    reject(new Error("Failed to load i18next script"));
                };
                document.head.appendChild(script);
            } else {
                resolve();
            }
        });
      }

    loadLabels() {
        fetch(`${labelsBranch}/labelsBranch.json`)
        .then(response => response.json())
        .then(data => {
            const userLocale = this.getLocale(); // Method to determine user locale (e.g., 'en', 'jp')
            
            // Initialize i18next with the fetched labels
            i18next.init({
                lng: userLocale,
                resources: {
                    [userLocale]: {
                        translation: data[userLocale]
                    }
                }
            }).then(() => {
                this.labels2 = i18next.store.data[userLocale].translation;
                console.log("User Locale: ", userLocale);
                console.log("User Labels: ", this.labels2);
            });
          })
          .catch((error) => {
            console.error("Error loading labels: ", error);
          });

    }

    getLocale() {
        const region = Intl.DateTimeFormat().resolvedOptions().locale;
        return region === "ja" ? "jp" : "en";
      }

    fetchBranchData() {
        BranchVehicleCount()
            .then(result => {
                this.branchData = Object.values(result);
                this.totalRecords = this.branchData.length;
                console.log("Branch Main Data",result);
                this.initializePageNumbers();
                this.fetchItems(this.currentPage);
                // Delay to ensure DOM updates
                setTimeout(() => {
                    this.updatePageButtons();
                }, 0);
                this.branchloader = false;
            })
            .catch(error => {
                console.error('Error loading branches:', error);
            });
    }

    initializePageNumbers() {
        let pages = Math.ceil(this.totalRecords / RECORDS_PER_PAGE);
        this.pageNumbers = Array.from({ length: pages }, (_, i) => i + 1);
        this.updateVisiblePageNumbers();
        this.updatePageButtons();
    }



    updateVisiblePageNumbers() {
        const totalVisiblePages = 5;
        const totalPages = this.pageNumbers.length;
    
        let startIdx = Math.max(this.currentPage - Math.ceil(totalVisiblePages / 2), 0);
        let endIdx = Math.min(startIdx + totalVisiblePages, totalPages);
    
        if (endIdx - startIdx < totalVisiblePages) {
            const diff = totalVisiblePages - (endIdx - startIdx);
            startIdx = Math.max(startIdx - diff, 0);
            endIdx = Math.min(startIdx + totalVisiblePages, totalPages);
        }
    
        this.visiblePageNumbers = this.pageNumbers.slice(startIdx, endIdx);
    
        this.isPreviousDisabled = this.currentPage === 1;
        this.isNextDisabled = this.currentPage === totalPages;
        console.log("tOOOTAALLLLLLLL PAGEE",totalPages);
    }
    

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.fetchItems(this.currentPage);
            this.updateVisiblePageNumbers();
            this.updatePageButtons();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.pageNumbers.length) {
            this.currentPage += 1;
            this.fetchItems(this.currentPage);
            this.updateVisiblePageNumbers();
            this.updatePageButtons();
        }
    }

    fetchItems(page) {
        console.log("Working Till FetchItems")
        const startIdx = (page - 1) * RECORDS_PER_PAGE;
        const endIdx = startIdx + RECORDS_PER_PAGE;
        this.paginatedBranchData = this.branchData.slice(startIdx, endIdx);
        this.isPageSelected = this.currentPage === page;
        console.log("Paginated Data", JSON.stringify(this.paginatedBranchData));
    }

    updatePageButtons() {
        const totalPages = this.pageNumbers.length;
        const buttons = this.template.querySelectorAll('.page-button');
        buttons.forEach(button => {
            const pageNum = Number(button.dataset.id);
            console.log("Current Page Number: ",pageNum);
            if (pageNum === this.currentPage) {
                button.classList.add('selected');
            } else {
                button.classList.remove('selected');
            }
        });

        this.isPreviousDisabled = this.currentPage === 1;
        this.isNextDisabled = this.currentPage === totalPages;
        console.log("tOOOTAALLLLLLLL PAGEE2",this.totalPages);
    }


    handlePageChange(event) {
        this.currentPage = Number(event.target.dataset.id);
        this.fetchItems(this.currentPage);
        this.updateVisiblePageNumbers();
        this.updatePageButtons();
    }
    
    branchesName;

    @wire(BranchVehicleCount)
    wiredBranchesNo({ error, data }) {
        if (data) {
            this.branchData = Object.values(data);
            console.log('Count', data.length);
            console.log('Total Entries', JSON.stringify(data.length));
            console.log(JSON.stringify(this.branchData));
            this.totalRecords = this.branchData.length;
            this.initializePageNumbers();
            this.fetchItems(this.currentPage); // Fetch items for initial page

        } else if (error) {
            console.error('Error loading branches:', error);
        }
    }
  
    handleBranchClick(event) {
        const branchId = event.target.dataset.idd;
        console.log("branch id", branchId); // Log the branchId to verify it's correct
        this.selectedBranch = this.branches.find(branch => branch.Id === branchId);
        this.selectedBranch = true;
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