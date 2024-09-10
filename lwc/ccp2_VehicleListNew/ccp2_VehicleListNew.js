import { LightningElement, track, wire } from "lwc";
import getVehicleData from "@salesforce/apex/CCP2_userData.userRegisteredVehicleList";
import getAllVehicleForDownload from "@salesforce/apex/ccp2_download_recall_controller.userListforDownload";
import totalPageCountApi from "@salesforce/apex/CCP2_userData.totalPageCount";
import seachVehicleDataApi from "@salesforce/apex/CCP2_VehicleDetailController.vehicleRegistrationAndDoorNo";
import listBySearchVehicle from "@salesforce/apex/CCP2_VehicleDetailController.getVehicleOnSearch";
// import updateFavVehicleApi from "@salesforce/apex/CCP2_VehicleDetailController.updateFavVehicle";
import Vehicle_StaticResource from "@salesforce/resourceUrl/CCP2_Resources";
const BACKGROUND_IMAGE_PC =
  Vehicle_StaticResource + "/CCP2_Resources/Common/Main_Background.webp";
const Filter =
  Vehicle_StaticResource + "/CCP2_Resources/Vehicle/filter_alt.png";
const Sort = Vehicle_StaticResource + "/CCP2_Resources/Vehicle/sort.png";
const Truckconnect =
  Vehicle_StaticResource + "/CCP2_Resources/Vehicle/truckConnect.png";
const Deleteveh =
  Vehicle_StaticResource + "/CCP2_Resources/Vehicle/delete_vehicle.png";
const download =
  Vehicle_StaticResource + "/CCP2_Resources/Vehicle/file_download.png";
const AddVehicle =
  Vehicle_StaticResource + "/CCP2_Resources/Vehicle/add_vehicle.png";
const TruckSampleImage =
  Vehicle_StaticResource + "/CCP2_Resources/Vehicle/TruckSample.png";
const NoVehicleIcon =
  Vehicle_StaticResource + "/CCP2_Resources/Vehicle/NoVehicles.png";

export default class Ccp2_VehicleListNew extends LightningElement {
  backgroundImagePC = BACKGROUND_IMAGE_PC;
  filtericon = Filter;
  DelVehIcon = Deleteveh;
  DownloadIcon = download;
  TruckconnectIcon = Truckconnect;
  SortIcon = Sort;
  addvehicleIcon = AddVehicle;
  truckSampleIcon = TruckSampleImage;
  noVehicleIcon = NoVehicleIcon;
  @track modalStyle = '';

  vehicleData = [];
  CarModel = [];
  brandModel = [];
  offSetCount = 10;
  @track vehicleListApiData;
  @track showListOffSet = false;
  @track showVehicleListOrNoVehicle = true;
  @track showVehicleList = true;
  @track showVehicleDetails = false;
  @track vehicleId;
  @track favIconForDetailPage;
  @track showVehicleModal = false;
  @track showSpinner = true;
  @track showDownload = false;
  @track showDownloadPath = false;
  @track showSuccessDownload = false;
  @track isStarFilled;
  //today's date
  @track currentDate;
  
  @track searchVehicleRegDoorData = [];
  @track filteredSearchVehicleRegDoorData = [];
  @track filterSuggestions = "";

  @track showFilteredSuggestions = false;
  @track FilterFlag = false;
  @track AllFlag = true;
  @track DownloadName = '日付- カスタマーポータル車両リスト.csv';
  @track allVehiclesData = [];
  @track filterData = [];
  @track searchFilter = false;

  // Pagination variables
  @track currentPagination = 10;
  @track totalPageForPagination = 5;
  @track totalPageCount = 1;
  @track currentPage = 1;
  @track showLeftDots = false;
  @track showRightDots = false;
  @track pageNumberCss = "page-button";
  @track currentPageNumberCss = "page-button cuurent-page";
  @track visiblePageCount = [1];
  @track prevGoing = false;
  @track TotalPageApiData;
  //filter modal variables 
  @track showFilterModal = false;


  vehicleBrachCount = 0;
  vehicleAccountCount = 0;

  renderedCallback() {
    this.updatePageButtons();
  }

  @wire(getVehicleData, {
    limitRange: "$currentPagination",
    pageNo: "$currentPage"
  })
  vehicledata(result) {
    console.log("wire for list is running!");
    this.vehicleListApiData = result;
    const { data, error } = result;
    if (data) {
      this.vehicleData = data.map((item) => {
        const { vehicle, branches, imageUrl } = item;

        // Map branch names
        let branchNames = branches.map((branch) => branch.Name);

        // Handle more than two branches
        if (branchNames.length > 2) {
          branchNames = `${branchNames.slice(0, 2).join("・")} 等`;
        } else {
          branchNames = branchNames.join("・");
        }

        let expDate = vehicle?.Vehicle_Expiration_Date__c
          ? this.formatJapaneseDate(vehicle.Vehicle_Expiration_Date__c)
          : "-";

        let starIcon =
          vehicle?.Favoruite_Vehicle__c === true
            ? "utility:favorite"
            : "utility:favorite_alt" || "utility:favorite_alt";
        let imageSrc = imageUrl.length === 0 ? this.truckSampleIcon : imageUrl;
        return {
          ...vehicle,
          starIcon,
          branchNames,
          imageSrc,
          expDate // Store the concatenated branch names
        };
      });
      this.showSpinner = false;
      console.log("redata", data);
    } else if (error) {
      console.error(error);
      this.showSpinner = true;
    }
  }

  @wire(totalPageCountApi, {
    limitRange: "$currentPagination",
    pageNo: "$currentPage"
  })
  totalCountFun(result) {
    this.TotalPageApiData = result;
    const { data, err } = result;
    if (data) {
      console.log("total vehicle count: - ", data);
      this.totalPageCount = data.totalPages;
      this.vehicleAccountCount = data.totalVehicleAccountCount;
      this.vehicleBrachCount = data.totalVehicleUserCount;

      this.updateVisiblePages();
    } else if (err) {
      console.error("error: - ", err);
    }
  }

  @wire(seachVehicleDataApi)
  searchDataFun({ data, err }) {
    if (data) {
      console.log("Search APi Data", data);
      let temData = [];
      if (Array.isArray(data))
        data.map((elm) => {
          if (elm?.Registration_Number__c)
            temData.push(elm.Registration_Number__c);
          if (elm?.Door_Number__c) temData.push(elm.Door_Number__c);
          return elm;
        });
      this.searchVehicleRegDoorData = temData;

      console.log("search data merged: - ", temData);
    } else if (err) {
      console.error("Search APi Error: - ", err);
    }
  }

  listBySearchVehicle(regOrDoorNumberSearched) {
    listBySearchVehicle({ str: regOrDoorNumberSearched })
      .then((data) => {
        this.filterData = data.map(record => {
         
          const { imageUrl, ...recordWithoutImageUrl } = record;
          
          return {
            ...recordWithoutImageUrl,
            branches: record.branches.map(branch => branch.Name) 
          };
        });

         console.log("filter",JSON.stringify(this.filterData));
        console.log("Data from sigle searched data:-", data[0]);
        // console.log('Data from sigle searched data:-',data.vehicle)
        const { vehicle, branches, imageUrl } = data[0];

        // Map branch names
        let branchNames = branches.map((branch) => branch.Name);

        // Handle more than two branches
        if (branchNames.length > 2) {
          branchNames = `${branchNames.slice(0, 2).join("・")} 等`;
        } else {
          branchNames = branchNames.join("・");
        }

        let expDate = vehicle?.Vehicle_Expiration_Date__c
          ? this.formatJapaneseDate(vehicle.Vehicle_Expiration_Date__c)
          : "-";

        let starIcon =
          vehicle?.Favoruite_Vehicle__c === true
            ? "utility:favorite"
            : "utility:favorite_alt" || "utility:favorite_alt";

        let imageSrc = imageUrl.length === 0 ? this.truckSampleIcon : imageUrl;
        this.vehicleData = [
          {
            ...vehicle,
            branchNames,
            starIcon,
            imageSrc,
            expDate // Store the concatenated branch names
          }
        ];

        this.showVehicleListOrNoVehicle = true;
        this.showSpinner = false;
        this.searchFilter = true;
      })
      .catch((err) => {
        console.error(err);
      });
  }

  connectedCallback() {
    const link = document.createElement("link");
    link.href =
      "https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@100..900&display=swap";
    link.rel = "stylesheet";
    document.head.appendChild(link);
    this.currentDate = this.getTodaysDate();
  }

  handlecardClick(event) {
    this.vehicleId = event.currentTarget.dataset.id;
    this.favIconForDetailPage = event.currentTarget.dataset.icon;
    console.log("Clicked Vehicle ID:", this.vehicleId);
    console.log("Clicked Vehicle icon:", this.favIconForDetailPage);
  
    this.showVehicleDetails = true;
    this.showVehicleList = false;
    window.scrollTo(0, 0);
  }
  handleBack() {
    this.currentPagination = this.currentPagination + 1;
   
    console.log("called");
    this.showVehicleList = true;
    this.showVehicleDetails = false;
  }

  showVehicleRegistration() {
    this.showVehicleModal = !this.showVehicleModal;
  }
  handleCloseModal() {
    this.showVehicleModal = false;
  }
  handlemoveModal() {
    this.showVehicleList = false;
  }


  toggleStar(event) {
    event.stopPropagation();
  }

  togglePaginationList() {
    this.showListOffSet = !this.showListOffSet;
  }

  clickOffSetElement(event) {
    console.log(event.target.title);
    this.currentPagination = event.target.title;
    this.currentPage = 1;
    this.updatePageButtons();
    this.updateVisiblePages();
  }

  pageCountClick(event) {
    console.log(event.target.title);
    this.currentPage = Number(event.target.title);
    this.updatePageButtons();
  }

  updatePageButtons() {
    console.log("in update pagination");
    const buttons = this.template.querySelectorAll(".page-button");
    buttons.forEach((button) => {
      const pageNum = Number(button.title);
      if (pageNum === this.currentPage) {
        console.log("Current Page Number clicked: ", pageNum);
        button.classList.add("cuurent-page");
      } else {
        button.classList.remove("cuurent-page");
      }
    });

    this.isPreviousDisabled = this.currentPage === 1;
    this.isNextDisabled = this.currentPage === this.totalPageCount;
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.prevGoing = true;
      this.currentPage -= 1;
      this.isPreviousDisabled = this.currentPage === 1;
      this.isNextDisabled = this.currentPage === this.totalPageCount;
      this.updatePageButtons();
    }
  }
  handleNextPage() {
    if (this.totalPageCount > this.currentPage) {
      this.prevGoing = false;
      this.currentPage += 1;
      console.log("THIS is the current page in handle next", this.currentPage);
      this.isPreviousDisabled = this.currentPage === 1;
      this.isNextDisabled = this.currentPage === this.totalPageCount;
      this.updatePageButtons();
    }
  }

  updateVisiblePages() {
    let startPage, endPage;

    if (this.currentPage <= 4) {
      startPage = 1;
      endPage = Math.min(4, this.totalPageCount);
    } else if (
      this.currentPage > 4 &&
      this.currentPage <= this.totalPageCount - 4
    ) {
      startPage = this.currentPage - 1;
      endPage = this.currentPage + 2;
    } else {
      startPage = this.totalPageCount - 3;
      endPage = this.totalPageCount;
    }

    
    this.visiblePageCount = [];
    for (let i = startPage; i <= endPage; i++) {
      this.visiblePageCount.push(i);
    }
  

    this.visiblePageCount.forEach((element) => {
      this.showRightDots = element === this.totalPageCount ? false : true;
    });
   
  }

  formatJapaneseDate(isoDate) {
    const date = new Date(isoDate);

    // Extract the year, month, and day
    const year = date.getFullYear();
    const month = date.getMonth() + 1; // getMonth() is zero-based
    const day = date.getDate();
    let reiwaYear;
    if (year === 2019) {
      if (month <= 4) {
        return `平成31年${month}月${day}日`;
      } else if (month > 4) {
        return `令和1年${month}月${day}日`;
      }
    } else if (year > 2019) {
      reiwaYear = year - 2018;
      return `令和${reiwaYear}年${month}月${day}日`;
    } else {
      reiwaYear = 30 - (2018 - year);
      return `平成${reiwaYear}年${month}月${day}日`;
    }

    return "NA";
  }
  getTodaysDate() {
    const today = new Date();
    const year = today.getFullYear();
    const month = ('0' + (today.getMonth() + 1)).slice(-2);  
    const day = ('0' + today.getDate()).slice(-2);  
    return `${day}-${month}-${year}`;
}

  handleSuggestionInputChange(event) {
    if (event.target.value === "") {
      this.currentPagination = this.currentPagination + 1;
      this.filterData = [];
      this.searchFilter = false;
      console.log("filterednew",this.filterData);
      setTimeout(() => {
        this.currentPagination = this.currentPagination - 1;
      }, 0);

      this.showVehicleListOrNoVehicle = true;
    }

    this.showFilteredSuggestions =
      event.target.value?.length > 0 ? true : false;

    this.filterSuggestions = event.target.value.toLowerCase();
    console.log(
      "event.target.value",
      event.target.value,
      "showFilteredSuggestions",
      this.showFilteredSuggestions,
      "filterSuggestions",
      this.filterSuggestions
    );

    if (this.showFilteredSuggestions) {
      this.filteredSearchVehicleRegDoorData =
        this.searchVehicleRegDoorData.filter((elm) =>
          elm.toLowerCase().startsWith(this.filterSuggestions)
        );
      console.log("iF", JSON.stringify(this.filteredSearchVehicleRegDoorData));
    } else {
      console.log("else");
      this.filteredSearchVehicleRegDoorData = [];
    }
  }

  handleKeyDown(event) {
    if (event.key === "Enter") {
      // Call the handleSuggestionInputChange function

      if (event.target?.value === "") {
        return;
      }
      if (this.filteredSearchVehicleRegDoorData?.length !== 0) {
        this.showSpinner = true;
        this.listBySearchVehicle(this.filteredSearchVehicleRegDoorData[0]);
        console.log('available search list :-',JSON.stringify(this.filteredSearchVehicleRegDoorData));
        this.showFilteredSuggestions = false;
      } else {
        this.showVehicleListOrNoVehicle = false;
        console.log("no data to show");

        this.showFilteredSuggestions = false;
      }
    }
  }

  handleSuggestionSelect(event) {
    this.showSpinner = true;
    this.listBySearchVehicle(event.target.textContent);
    this.showFilteredSuggestions = false;
  }

  // adjustDropdownPosition() {
  //   const dropdownContainer = this.template.querySelector(
  //     ".drop-down-container"
  //   );
  //   const dropdownList = this.template.querySelector(".drop-down-list");

  //   console.log("WHAT WE HAVE TO DROPDOWN:- ", dropdownContainer, dropdownList);
  //   const containerRect = dropdownContainer.getBoundingClientRect();
  //   const listHeight = dropdownList.offsetHeight;

  //   const spaceBelow = window.innerHeight - containerRect.bottom;
  //   const spaceAbove = containerRect.top;
  //   console.log("WHAT:- ", containerRect, listHeight, spaceBelow, spaceAbove);

  //   if (spaceBelow < listHeight && spaceAbove > listHeight) {
  //     console.log("IN IF :- ");
  //     dropdownList.style.bottom = "unset";
  //     dropdownList.style.top = "44px"; // Adjust the value based on your layout
  //   } else {
  //     console.log("IN ELSE :- ");
  //     dropdownList.style.top = "unset";
  //     dropdownList.style.bottom = "44px";
  //   }
  // }
  get hasVehicles() {
    return this.vehicleAccountCount > 0;
}
//download feature
//modal 1
  showDownloadModal(){
    this.showDownload = true;
    this.DownloadName = `${this.currentDate} - カスタマーポータル車両リスト.csv`;
  }
  closeDownload(){
    this.FilterFlag = false;
    this.AllFlag = true;
    this.showDownload = false;
  }
  MovetoRename(){
    if(this.AllFlag == true ){
       this.allApex();
    }
    if(this.searchFilter == true){
      this.allVehiclesData = [];
      this.allVehiclesData = this.filterData;
    }
    if(this.searchFilter == false && this.AllFlag == false){
      this.allApex();
    }
    this.showDownload = false;
    this.showDownloadPath = true;
  }
  closePathDownload(){
    this.DownloadName = `${this.currentDate} - カスタマーポータル車両リスト.csv`;
    this.FilterFlag = false;
    this.AllFlag = true;
    this.showDownloadPath = false;
  }
  finaldownload(){
    this.downloadCSVAll();
    this.showFinishTimeModal();
    this.showDownloadPath =false;
  }
  showFinishTimeModal() {
    this.showSuccessDownload = true;
    window.scrollTo(0,0);
    setTimeout(() => {
        this.DownloadName = `${this.currentDate} - カスタマーポータル車両リスト.csv`;
        this.FilterFlag = false;
        this.AllFlag = true;
        this.showSuccessDownload = false;
    }, 2000);
}
FilterOption(event){
  this.FilterFlag = event.target.checked;
  if (this.FilterFlag) {
    this.AllFlag = false;
  }
  console.log("de",this.allVehiclesData);
}
Alloption(event){
  this.AllFlag= event.target.checked;
    if (this.AllFlag) {
      this.FilterFlag = false;
   }
}
allApex(){
  getAllVehicleForDownload()
  .then((result) => {
      this.allVehiclesData = [];
      this.allVehiclesData = result;
      console.log('All Vehicle Data:',JSON.stringify(result));
  })
  .catch((error) => {
      console.error('Error retrieving vehicle data:', error);
  });
}

downloadCSVAll() {
  if (this.allVehiclesData.length === 0) {
    console.error('No data available to download');
    return;
}

const headers = [
    '車両番号',
    '登録番号',
    '車台番号',
    '交付年月日',
    '車名',
    '自動車の種別',
    '車体形状',
    '車両重量',
    '初度登録年月日',
    '有効期間の満了日',
    '走行距離',
    '燃料の種類',
    '自家用・事業用の別',
    '用途',
    '型式',
    'ドアナンバー',
    '所属'
];

const csvRows = this.allVehiclesData.map(record => {
    const vehicle = record.vehicle;
    const branches = Array.isArray(record.branches) 
    ? record.branches.join('・') 
    : record.branches ? record.branches.name : ''; 

    return [
        vehicle.Vehicle_Number__c || '',
        vehicle.Registration_Number__c || '',
        vehicle.Chassis_number__c || '',
        vehicle.Delivery_Date__c || '',
        vehicle.Vehicle_Name__c || '',
        vehicle.Vehicle_Type__c || '',
        vehicle.Body_Shape__c || '',
        vehicle.vehicleWeight__c || '', 
        vehicle.First_Registration_Date__c || '',
        vehicle.Vehicle_Expiration_Date__c || '',
        vehicle.Mileage__c || '',
        vehicle.Fuel_Type__c || '',
        vehicle.Private_Business_use__c || '',
        vehicle.Use__c || '',
        vehicle.fullModel__c || '',
        vehicle.Door_Number__c || '', 
        branches
    ];
});


let csvContent = headers.join(',') + '\n';
csvRows.forEach(row => {
    csvContent += row.join(',') + '\n';
});
const BOM = '\uFEFF'; 
csvContent = BOM + csvContent;
  
const csvBase64 = btoa(unescape(encodeURIComponent(csvContent)));
        const link = document.createElement('a');
        link.href = 'data:text/csv;base64,' + csvBase64;
        link.download = `${this.DownloadName}.csv`;
        link.click();
        window.URL.revokeObjectURL(link.href);
        link.remove();
}
  handleDownloadChange(event){
     this.DownloadName = event.target.value;
  }
  //filter Modal 
  openFilterModal(){
    this.showFilterModal = true;
    document.body.style.overflow = 'hidden';
  }
  closeFilterModal(){
    this.showFilterModal = false;
    document.body.style.overflow = '';
  }
}