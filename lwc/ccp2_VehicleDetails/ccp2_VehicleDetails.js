import { LightningElement, wire, track, api } from "lwc";
import getVehicleById from "@salesforce/apex/CCP2_VehicleDetailController.getVehicleById";
import getImagesAsBase64 from "@salesforce/apex/VehicleImageService.getImagesAsBase64";
import vehicleBranchName from "@salesforce/apex/CCP2_VehicleDetailController.vehicleBranchName";
import getVehicleCertificates from "@salesforce/apex/CCP2_VehicleDetailController.vehicleImageCountTitle";
import updateFavVehicleApi from "@salesforce/apex/CCP2_VehicleDetailController.updateFavVehicle";
import truckonnectLogo from "@salesforce/resourceUrl/CCP2_Truckonnect";
import CCP2_Resources from "@salesforce/resourceUrl/CCP2_Resources";
import CCP2_ScheduleRegistration from "@salesforce/label/c.CCP2_ScheduleRegistration";
import CCP2_ExpenseRegistration from "@salesforce/label/c.CCP2_ExpenseRegistration";
import CCP2_CarName from "@salesforce/label/c.CCP2_CarName";
import CCP2_CarModel from "@salesforce/label/c.CCP2_CarModel";
import CCP2_Maker from "@salesforce/label/c.CCP2_Maker";
import CCP2_Capacity from "@salesforce/label/c.CCP2_Capacity";
import CCP2_Displacement from "@salesforce/label/c.CCP2_Displacement";
import CCP2_Plate from "@salesforce/label/c.CCP2_Plate";
import CCP2_Year from "@salesforce/label/c.CCP2_Year";
import CCP2_Mileage from "@salesforce/label/c.CCP2_Mileage";
import CCP2_Edit from "@salesforce/label/c.CCP2_Edit";
import CCP2_Mark from "@salesforce/label/c.CCP2_Mark";
import CCP2_VehicleDetails from "@salesforce/label/c.CCP2_VehicleDetails";
import CCP2_MaintenanceList from "@salesforce/label/c.CCP2_MaintenanceList";
import CCP2_ExpenseManagement from "@salesforce/label/c.CCP2_ExpenseManagement";
import CCP2_ChassisInformation from "@salesforce/label/c.CCP2_ChassisInformation";
import CCP2_LoadingPlatformInformation from "@salesforce/label/c.CCP2_LoadingPlatformInformation";
import CCP2_PartsInformation from "@salesforce/label/c.CCP2_PartsInformation";
import CCP2_LeaseInformation from "@salesforce/label/c.CCP2_LeaseInformation";
import CCP2_CommonCarName from "@salesforce/label/c.CCP2_CommonCarName";
import CCP2_BodyColor from "@salesforce/label/c.CCP2_BodyColor";
import CCP2_ChassisNumber from "@salesforce/label/c.CCP2_ChassisNumber";
import CCP2_CurrentParkingSpot from "@salesforce/label/c.CCP2_CurrentParkingSpot";
import CCP2_NoxPMRegulations from "@salesforce/label/c.CCP2_NoxPMRegulations";
import CCP2_VehicleModel from "@salesforce/label/c.CCP2_VehicleModel";
import CCP2_LastVehicleInspectionDate from "@salesforce/label/c.CCP2_LastVehicleInspectionDate";
import CCP2_DeliveryDay from "@salesforce/label/c.CCP2_DeliveryDay";
import CCP2_DriversLicence from "@salesforce/label/c.CCP2_DriversLicence";
import CCP2_FirstYearRegistrationDate from "@salesforce/label/c.CCP2_FirstYearRegistrationDate";
import CCP2_BodyMaker from "@salesforce/label/c.CCP2_BodyMaker";
import CCP2_BodyInternalDimmension from "@salesforce/label/c.CCP2_BodyInternalDimmension";
import CCP2_BodyShape from "@salesforce/label/c.CCP2_BodyShape";
import CCP2_MaximumLoadingCapacity from "@salesforce/label/c.CCP2_MaximumLoadingCapacity";
import CCP2_BodyMounting from "@salesforce/label/c.CCP2_BodyMounting";
import CCP2_Download from "@salesforce/label/c.CCP2_Download";
import CCP2_Print from "@salesforce/label/c.CCP2_Print";

const editIcon = CCP2_Resources + "/CCP2_Resources/Vehicle/write.png";
const vehicleIcon =
  CCP2_Resources + "/CCP2_Resources/Vehicle/delete_vehicle.png";
const downloadIcon =
  CCP2_Resources + "/CCP2_Resources/Vehicle/file_download.png";

export default class Ccp2_VehicleDetails extends LightningElement {
  @track vehicleByIdLoader = true;
  @api vehicleIcons;
  @api vehicleId;
  @track showVehicleDetails = true;
  @track showCostManagement = false;
  @track showMaintainList = false;
  @track showvehDetails = true;
  @track showMaintainencePage = false;
  @track BranchesModal = false;
  @track morethanOneBranch = true;
  @track showone = true;
  @track classVehicleDetails = "";
  @track classCostManagement = "";
  @track classMaintainList = "";
  @track vehId = "";
  @track uploadImageCss = "upload-image";
  @track uploadCertImagesArray = [];
  @track isModalOpen = false;

  @track uploadImageCss = "upload-image";
  @track uploadImagesArray = [];
  @track isModalOpen = false;
  @track noImagesAvailable = false;
  @track imagesAval = false;
  editIcon = editIcon;
  vehicleIcon = vehicleIcon;
  downloadIcon = downloadIcon;
  isStarFilled = false;
  @track certificateTitleCount = "-";
  @track Branches = [];
  @track isImageModalOpen = true;
  @track imagesAvailable = true;
  @track currentImageIndex = 0;
  @track isLastPage = true;
  @track isFirstPage = true;
  @track totalPages = 1;
  truckLogoUrl = truckonnectLogo;
  // @api showVehicle;
  @track vehicleByIdData = {
    id: 100,
    name: "-",
    type: "-",
    carBodyShape: "-",
    chassisNumber: "-",
    doorNumber: "-",
    firstRegistrationDate: "-",
    Favourite: "-",
    typeOfFuel: "-",
    mileage: "-",
    branch: "-",
    branchCount: "-",
    branchReal: "-",
    OnScreenBranchCount: "-",
    privateBusinessUse: "-",
    vehicleNumber: "-",
    affiliation: "-",
    vehicleInspectionCertificateIssueDate: "-",
    vehicleInspectionImage: "-",
    purpose: "-",
    model: "-",
    vehicleWeigth: "-",
    registerationNumber: "-",
    expirationDate: "-",
    devileryDate: "-"
  };

  label = {
    CCP2_ScheduleRegistration: CCP2_ScheduleRegistration,
    CCP2_ExpenseRegistration: CCP2_ExpenseRegistration,
    CCP2_CarName: CCP2_CarName,
    CCP2_CarModel: CCP2_CarModel,
    CCP2_Maker: CCP2_Maker,
    CCP2_Capacity: CCP2_Capacity,
    CCP2_Displacement: CCP2_Displacement,
    CCP2_Plate: CCP2_Plate,
    CCP2_Year: CCP2_Year,
    CCP2_Mileage: CCP2_Mileage,
    CCP2_Edit: CCP2_Edit,
    CCP2_Mark: CCP2_Mark,
    CCP2_VehicleDetails: CCP2_VehicleDetails,
    CCP2_MaintenanceList: CCP2_MaintenanceList,
    CCP2_ExpenseManagement: CCP2_ExpenseManagement,
    CCP2_ChassisInformation: CCP2_ChassisInformation,
    CCP2_LoadingPlatformInformation: CCP2_LoadingPlatformInformation,
    CCP2_PartsInformation: CCP2_PartsInformation,
    CCP2_LeaseInformation: CCP2_LeaseInformation,
    CCP2_CommonCarName: CCP2_CommonCarName,
    CCP2_BodyColor: CCP2_BodyColor,
    CCP2_ChassisNumber: CCP2_ChassisNumber,
    CCP2_CurrentParkingSpot: CCP2_CurrentParkingSpot,
    CCP2_NoxPMRegulations: CCP2_NoxPMRegulations,
    CCP2_VehicleModel: CCP2_VehicleModel,
    CCP2_LastVehicleInspectionDate: CCP2_LastVehicleInspectionDate,
    CCP2_DeliveryDay: CCP2_DeliveryDay,
    CCP2_DriversLicence: CCP2_DriversLicence,
    CCP2_FirstYearRegistrationDate: CCP2_FirstYearRegistrationDate,
    CCP2_BodyMaker: CCP2_BodyMaker,
    CCP2_BodyInternalDimmension: CCP2_BodyInternalDimmension,
    CCP2_BodyShape: CCP2_BodyShape,
    CCP2_MaximumLoadingCapacity: CCP2_MaximumLoadingCapacity,
    CCP2_BodyMounting: CCP2_BodyMounting,
    CCP2_Download: CCP2_Download,
    CCP2_Print: CCP2_Print
  };

  @api currentChassisNumber;
  @track allImages;
  @track uploadCertImagesArray = this.allCertificates || null;

  updateFavVehicle(vehId, favBool, favIconName) {
    updateFavVehicleApi({ vehicleId: vehId, favVehicle: favBool })
      .then(() => {
        console.log("Vehicle Favourite icon updated!!");
        if (favIconName === "utility:favorite") {
          this.vehicleByIdData.Favourite = "utility:favorite_alt";
        } else {
          this.vehicleByIdData.Favourite = "utility:favorite";
        }
      })
      .catch((err) => {
        console.log("Vehicle Favourite icon updated!!", vehId, favBool);
        console.error(err);
      });
  }

  @wire(getVehicleById, { vehicleId: "$vehicleId" }) handledata({
    data,
    error
  }) {
    if (data) {
      console.log("geting from vehicle by Id: ", this.vehicleId);
      console.log("geting from vehicle by Id api: ", data);
      this.vehId = this.vehicleId;
      if (data.length !== 0) {
        let obj = {
          id: data[0].Id === undefined ? "-" : data[0].Id,
          name:
            data[0].Vehicle_Name__c === undefined
              ? "-"
              : data[0].Vehicle_Name__c,
          type:
            data[0].Vehicle_Type__c === undefined
              ? "-"
              : data[0].Vehicle_Type__c,
          Favourite: this.vehicleIcons,
          carBodyShape:
            data[0].Body_Shape__c === undefined ? "-" : data[0].Body_Shape__c,
          chassisNumber:
            data[0].Chassis_number__c === undefined
              ? "-"
              : data[0].Chassis_number__c,
          doorNumber:
            data[0].Door_Number__c === undefined ? "-" : data[0].Door_Number__c,
          firstRegistrationDate:
            data[0].First_Registration_Date__c === undefined
              ? "-"
              : this.formatJapaneseDate(data[0].First_Registration_Date__c), // Apply Japanese date formatting

          typeOfFuel:
            data[0].Fuel_Type__c === undefined ? "-" : data[0].Fuel_Type__c,
          mileage: data[0].Mileage__c === undefined ? "-" : data[0].Mileage__c,
          privateBusinessUse:
            data[0].Private_Business_use__c === undefined
              ? "-"
              : data[0].Private_Business_use__c,
          vehicleNumber:
            data[0].Vehicle_Number__c === undefined
              ? "-"
              : data[0].Vehicle_Number__c,
          affiliation:
            data[0].affiliation === undefined ? "-" : data[0].affiliation,
          vehicleWeigth:
            data[0].vehicleWeight__c === undefined
              ? "-"
              : data[0].vehicleWeight__c,
          model:
            data[0].fullModel__c === undefined ? "-" : data[0].fullModel__c,
          purpose: data[0].Use__c === undefined ? "-" : data[0].Use__c,
          vehicleInspectionImage:
            data[0].vehicleInspectionImage === undefined
              ? "-"
              : data[0].vehicleInspectionImage,
          vehicleInspectionCertificateIssueDate:
            data[0].vehicleInspectionCertificateIssueDate === undefined
              ? "-"
              : this.formatJapaneseDate(
                  data[0].vehicleInspectionCertificateIssueDate
                ), // Apply Japanese date formatting
          registerationNumber:
            data[0].Registration_Number__c === undefined
              ? "-"
              : data[0].Registration_Number__c,
          expirationDate:
            data[0].Vehicle_Expiration_Date__c === undefined
              ? "-"
              : this.formatJapaneseDate(data[0].Vehicle_Expiration_Date__c),
          devileryDate:
            data[0].Delivery_Date__c === undefined
              ? "-"
              : this.formatJapaneseDate(data[0].Delivery_Date__c)
        };
        console.log("object geting from vehicle by Id api: ", obj);
        this.vehicleByIdData = obj;
        this.currentChassisNumber =
          data[0].Chassis_number__c === undefined
            ? ""
            : data[0].Chassis_number__c;
        this.loadbranches();
        this.fetchVehicleCertificates();
      }
    } else if (error) {
      // handle error
      console.error("geting from vehicle by Id api: ", error);
    }
  }

  loadbranches() {
    vehicleBranchName({ vehicleId: this.vehicleId })
      .then((data) => {
        console.log("Getting Branch from vehicle by Id: ", this.vehicleId);
        console.log("Getting Branch from vehicle by Id API: ", data);

        this.vehId = this.vehicleId;

        if (data.length !== 0) {
          this.Branches = data;
          if (this.Branches.length == 1) {
            this.morethanOneBranch = false;
          }
          this.vehicleByIdData.branchReal = this.Branches[0].Name;
          this.Branches.forEach(branch => {
            const branchNumberStr = branch.Branch_Code__c.toString(); // Convert branchno to string

            // Extract the first and last characters
            const firstDigit = branchNumberStr.charAt(0);
            const lastDigit = branchNumberStr.charAt(branchNumberStr.length - 1);

            // Check if both first and last digits are between 0 and 9
            if (firstDigit >= '0' && firstDigit <= '9' &&
                lastDigit >= '0' && lastDigit <= '9') {
                this.showone = true;
            } else {
                this.showone = false;
            }
        });
          this.vehicleByIdData.branch = this.abbreviateName(this.Branches[0].Name) || "-";

          this.vehicleByIdData.branchCount = this.Branches.length;
          this.vehicleByIdData.OnScreenBranchCount =
            this.vehicleByIdData.branchCount - 1;
          this.Branches = data.map((branch) => ({
            ...branch,
            originalName: branch.Name,
            Name:
              branch.Name.length > 11
                ? `${branch.Name.slice(0, 7)}...`
                : branch.Name,
            originalMinicipalities: branch.Minicipalities__c,
            Minicipalities__c:
              branch.Minicipalities__c && branch.Minicipalities__c.length > 11
                ? `${branch.Minicipalities__c.slice(0, 7)}...`
                : branch.Minicipalities__c
          }));
          console.log(
            "Branch assigned to vehicleByIdData.branch: ",
            this.vehicleByIdData.branch
          );
          // console.log("Branch data from API: ", JSON.stringify(this.Branches));
        } else {
          this.vehicleByIdData.branch = "-";
          this.vehicleByIdData.branchCount = " ";
          this.morethanOneBranch = false;
          console.log("No branches found, setting branch to '-'.");
        }
      })
      .catch((error) => {
        console.error("Error getting Branch from vehicle by Id API: ", error);
      });
  }
  abbreviateName(name, maxLength = 11) {
    if (name && name.length > maxLength) {
        return `${name.slice(0, 5)}...`;
    }
    return name;
}

  @track allCertificates = [];
  @track vehicleByIdLoader2 = false;

  @wire(getImagesAsBase64, { chassisNumber: "$currentChassisNumber" })
  handleImages({ data, error }) {
    console.log("Chassis Number for Image", this.currentChassisNumber);

    // Start loaders
    this.vehicleByIdLoader2 = true;
    this.vehicleByIdLoader3 = true;
    this.imagesAvailable = false;
    this.certificatesAvailable = false;

    if (data) {

      try {
        data = JSON.parse(data);
        console.log("Parsed Data", data);

        // Handle Images
        if (Array.isArray(data.Images) && data.Images.length > 0) {
          this.allImages = data.Images;
          this.totalPages = data.Images.length;
          console.log("Total Pages: ", this.totalPages);
          this.imagesAvailable = true; // Images are available
        } else {
          this.allImages = [];
          this.imagesAvailable = false; // No images available
        }

        // Handle Certificates
        if (Array.isArray(data.Certificates) && data.Certificates.length > 0) {
          this.allCertificates = data.Certificates;
          this.certificatesAvailable = true; // Certificates are available
        } else {
          this.allCertificates = [];
          this.certificatesAvailable = false; // No certificates available
        }

      } catch (e) {
        console.error("Error parsing data:", e);
        this.imagesAvailable = false;
        this.certificatesAvailable = false;
      } finally {
        this.vehicleByIdLoader2 = false; // Images loading complete
        this.vehicleByIdLoader3 = false; // Certificates loading complete
        this.isLastPage = this.currentImageIndex === this.totalPages - 1;
      }
    } else if (error) {
      // handle error
      this.imagesAvailable = false;
      this.certificatesAvailable = false;
      this.vehicleByIdLoader2 = false; // Images loading complete with error
      this.vehicleByIdLoader3 = false; // Certificates loading complete with error
      console.error(
        "Error getting data from vehicle by Chassis Number API: ",
        error
      );
    }
  }

  formatBranchNumber(branchCount) {
    if(branchCount != null){

        let count = branchCount;

        if (count < 100) {
            return `00${count}`;
        } else if (count >= 100 && count < 1000) {
            return `0${count}`;
        } else {
            return `${count}`;
        }
    }
}
  

  @api openModalWithImages(imageData) {
    if (Array.isArray(imageData) && imageData.length > 0) {
      this.uploadImagesArray = imageData.map((image) => ({
        fileName: image.fileName,
        fileURL: image.fileURL
      }));
      this.noImagesAvailable = false;
    } else {
      this.uploadImagesArray = [];
      this.noImagesAvailable = true;
    }
    this.uploadImageCss =
      this.uploadImagesArray.length === 1
        ? "upload-image one-element"
        : "upload-image";

    this.isModalOpen = true;
  }

  handleCloseModal() {
    this.isModalOpen = false;
  }

  handleCertificateClick() {
    if (
      Array.isArray(this.allCertificates) &&
      this.allCertificates.length > 0
    ) {
      this.uploadImagesArray = this.allCertificates.map((certificate) => {
        let processedImageName = certificate.fileName;

        if (certificate.fileName.length > 7) {
          processedImageName = `${certificate.fileName.slice(0, 3)}...${certificate.fileName.slice(-5)}`;
        }

        return {
          fileName: certificate.fileName,
          fileURL: certificate.fileURL,
          ProcessedFileName: processedImageName
        };
      });
      this.imagesAval = true;
    } else {
      this.uploadImagesArray = [];
      this.imagesAval = false;
    }
    this.isModalOpen = true;
  }

  


  renderedCallback(){
    console.log(`%cThis is green text connected ${this.vehicleIcons}' , 'color: green;`);
    this.vehicleByIdData.Favourite = this.vehicleIcons;
  }

  connectedCallback() {
    this.isFirstPage = this.currentImageIndex === 0;
    this.isLastPage = true;
    console.log(`%cThis is green text connected ${this.vehicleIcons}' , 'color: green;`);
    this.vehicleByIdData.Favourite = this.vehicleIcons;
  }

  get visibleDots() {
    const totalDots = this.allImages.length;
    const maxVisibleDots = 6;
    let start = Math.max(
      0,
      this.currentImageIndex - Math.floor(maxVisibleDots / 2)
    );
    let end = start + maxVisibleDots;

    if (end > totalDots) {
      end = totalDots;
      start = Math.max(0, end - maxVisibleDots);
    }

    return this.allImages.slice(start, end).map((img, index) => {
      return {
        key: img.fileName,
        class:
          start + index === this.currentImageIndex
            ? "image-dot active"
            : "image-dot"
      };
    });
  }

  handleDownloadImage(event) {
    // Get the image URL and name from the data attributes of the clicked SVG
    let imageUrl = event.target.getAttribute("data-url");
    let imageName = event.target.getAttribute("data-name");
    if (imageUrl && imageName) {
      // Create a temporary anchor element
      const link = document.createElement("a");
      link.href = imageUrl;
      link.download = imageName; // Set the file name for the download

      // Append the link to the body and trigger the click event
      document.body.appendChild(link);
      link.click();

      // Remove the link from the body
      document.body.removeChild(link);
    } else {
      console.error("Image URL or name not found.");
    }
  }

  populateImages() {
    // Simulate fetching or assigning images (replace this with your actual data-fetching logic)
    const fetchedImages = [
      { fileName: "Image1", fileURL: "data:image/jpeg;base64,..." },
      { fileName: "Image2", fileURL: "data:image/jpeg;base64,..." },
      { fileName: "Image3", fileURL: "data:image/jpeg;base64,..." }
    ];

    if (Array.isArray(fetchedImages) && fetchedImages.length > 0) {
      this.allImages = fetchedImages.map((image) => ({
        fileName: image.fileName,
        fileURL: image.fileURL
      }));
      // console.log("Image Here: ", JSON.stringify(this.allImages));
      this.imagesAvailable = true;
    } else {
      this.allImages = [];
      this.imagesAvailable = false;
    }
  }

  get currentImage() {
    return this.allImages[this.currentImageIndex];
  }

  get isPreviousDisabled() {
    return this.currentImageIndex === 0;
  }

  get isNextDisabled() {
    return this.currentImageIndex === this.allImages.length - 1;
  }

  
  renderedCallback() {
    this.isLastPage = this.currentImageIndex === this.totalPages - 1;
    this.isFirstPage = this.currentImageIndex === 0;
  }

  showPreviousImage() {
    if (this.currentImageIndex > 0) {
      this.isFirstPage = false;
      this.currentImageIndex -= 1;
    }
  }

  showNextImage() {
    if (this.currentImageIndex < this.allImages.length - 1) {
      this.currentImageIndex += 1;
    }
  }

  fetchVehicleCertificates() {
    getVehicleCertificates({ vehicleId: this.vehicleId })
      .then((data) => {
        const lengthOfTitle = data.titles ? data.titles[0].length : 0;
        if (lengthOfTitle > 15) {
          this.certificateTitleCount = data.titles
            ? data.titles[0].substring(0, 15) + "...など" + data.count + "枚"
            : "-";
        } else {
          this.certificateTitleCount = data.titles
            ? data.titles[0] + "など" + data.count + "枚"
            : "-";
        }
        this.vehicleByIdLoader = false;
      })
      .catch((error) => {
        this.certificateTitleCount = "-";
        console.error("Fetching from vehicle Certificate API: ", error);
        this.vehicleByIdLoader = false;
      });
  }

  dothis() {
    console.log("dothis function called");
  }

  showVehicleDetailFun() {
    this.showVehicleDetails = true;
    this.showMaintainList = false;
    this.showCostManagement = false;
    this.classVehicleDetails = "underline";
    this.classCostManagement = "";
    this.classMaintainList = "";
  }
  showCostManagementFun() {
    this.showVehicleDetails = false;
    this.showMaintainList = false;
    this.showCostManagement = true;
    this.classVehicleDetails = "";
    this.classCostManagement = "underline";
    this.classMaintainList = "";
  }
  showMaintainListFun() {
    this.showVehicleDetails = false;
    this.showMaintainList = true;
    this.showCostManagement = false;
    this.classVehicleDetails = "";
    this.classCostManagement = "";
    this.classMaintainList = "underline";
  }

  closeDetailPage() {
    this.dispatchEvent(new CustomEvent("back"));
  }



  toggleStar(event) {
    let boolFav;
    if (event.target.iconName === "utility:favorite") {
      boolFav = false;
    } else {
      boolFav = true;
    }
    this.updateFavVehicle(
      event.target.dataset.vehicleId,
      boolFav,
      event.target.iconName
    );
  }

  gotoMaintainencePage() {
    this.showMaintainencePage = true;
    this.showvehDetails = false;
    window.scrollTo(0, 0);
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
    }
    else {
      reiwaYear = 30 - (2018 - year);
      return `平成${reiwaYear}年${month}月${day}日`;
    }
  }

  // not in use
  handlebackhere() {
    console.log("calledbydev");
    this.showvehDetails = true;
    this.showMaintainencePage = false;
    window.scrollTo(0, 0);
  }

  branchopen() {
    this.BranchesModal = true;
  }
  branchClose() {
    this.BranchesModal = false;
  }
}