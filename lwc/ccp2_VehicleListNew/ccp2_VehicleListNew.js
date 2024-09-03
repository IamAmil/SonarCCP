import { LightningElement, track, wire } from "lwc";
import getVehicleData from "@salesforce/apex/CCP2_userData.userRegisteredVehicleList";
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

  vehicleData = [];
  CarModel = [];
  brandModel = [];
  offSetCount = 10;
  vehicleAccountCount = 0;
  vehicleBrachCount = 0;
  @track vehicleListApiData;
  @track TotalPageApiData;
  @track showListOffSet = false;
  @track showVehicleListOrNoVehicle = true;
  @track showVehicleList = true;
  @track showVehicleDetails = false;
  @track vehicleId;
  @track favIconForDetailPage;
  @track showVehicleModal = false;
  @track showSpinner = true;
  @track isStarFilled;
  @track currentPagination = 10;
  @track totalPageForPagination = 5;
  @track totalPageCount = 1;
  @track currentPage = 1;
  @track showLeftDots = false;
  @track showRightDots = false;
  @track pageNumberCss = "page-button";
  @track currentPageNumberCss = "page-button cuurent-page";
  @track visiblePageCount = [1];
  @track searchVehicleRegDoorData = [];
  @track filteredSearchVehicleRegDoorData = [];
  @track filterSuggestions = "";
  @track prevGoing = false;
  @track showFilteredSuggestions = false;

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
        // vehicle.Vehicle_Expiration_Date__c = 'null';

        let imageSrc = imageUrl.length === 0 ? this.truckSampleIcon : imageUrl;
        return {
          ...vehicle,
          starIcon,
          branchNames,
          imageSrc,
          expDate // Store the concatenated branch names
        };
      });

      // this.vehicleAccountCount = this.vehicleData.length;
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
        // vehicle.Vehicle_Expiration_Date__c = 'null';

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
    // this.showSpinner = true;
  }

  handlecardClick(event) {
    this.vehicleId = event.currentTarget.dataset.id;
    this.favIconForDetailPage = event.currentTarget.dataset.icon;
    console.log("Clicked Vehicle ID:", this.vehicleId);
    console.log("Clicked Vehicle icon:", this.favIconForDetailPage);
    // this.dispatchEvent(new CustomEvent('vehicleclick', { detail: vehicleId }));
    this.showVehicleDetails = true;
    this.showVehicleList = false;
    window.scrollTo(0, 0);
  }
  handleBack() {
    this.currentPagination = this.currentPagination + 1;
    // setTimeout(() => {
    //   this.currentPagination = this.currentPagination - 2;
    // }, 1);
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
  //star store
  // get starIcon() {
  //   return this.isStarFilled ? "utility:favorite" : "utility:favorite_alt";
  // }

  toggleStar(event) {
    event.stopPropagation();
    // console.log('event.target.classList',event.target)
  }

  togglePaginationList() {
    this.showListOffSet = !this.showListOffSet;

    // if (this.showListOffSet) {
    //   this.adjustDropdownPosition();
    // }
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

    // if (this.currentPage < 4 || this.prevGoing) {
    this.visiblePageCount = [];
    for (let i = startPage; i <= endPage; i++) {
      this.visiblePageCount.push(i);
    }
    // } else if (this.currentPage === 5 || this.currentPage % 4 === 0) {
    //   this.visiblePageCount = [];
    //   for (let i = startPage; i <= endPage; i++) {
    //     this.visiblePageCount.push(i);
    //   }
    // }

    this.visiblePageCount.forEach((element) => {
      this.showRightDots = element === this.totalPageCount ? false : true;
    });
    // if (this.totalPageCount > 4) {
    //   this.showRightDots = true;
    // //   this.visiblePageCount.pop();
    // }
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

  handleSuggestionInputChange(event) {
    if (event.target.value === "") {
      this.currentPagination = this.currentPagination + 1;
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
}