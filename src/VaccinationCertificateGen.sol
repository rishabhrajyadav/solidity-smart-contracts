// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaccineCertification is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _certificateIdCounter;
    Counters.Counter private _centerIdCounter;
    Counters.Counter private _patientIdCounter;
   
    error NotAnAuthorizedParty();
    error InvalidCenterId();
    error InvalidPatientId();
    error InvalidCenterParams();
    error InvalidPatientDetails();
    error AlreadyVerified();
    error CenterAlreadyExist();
    error PatientAlreadyExist();
    error PatientAlreadyHasCertificate();
    error CertificateNotExist();

    struct Center {
        address center;
        string centerName;
        string leadBy;
        string centerAddress;
        string location;
    }

    struct Patient {
        string name;
        string dateOfBirth;
        string contactInformation;
        string vaccineType;
        string vaccinationDate;
    }

    struct Certificate {
        bool isVerified;
        address certficateGenerator;
        address patient;
        uint256 patientId;
    }

    mapping(uint256 => Center) public centers;
    mapping(uint256 => Patient) public patients;
    mapping(uint256 => Certificate) public certificates;
    mapping(address => bool) public authorizedCenters;
    mapping(uint256 => bytes32) private patientHashes;


    modifier onlyOwnerOrCenter() {
        if(msg.sender != owner() && !authorizedCenters[msg.sender]) revert NotAnAuthorizedParty();
        _;
    }

    modifier validCenterId(uint256 _centerId){
        uint256 centerId = _centerIdCounter.current();
        if(_centerId > centerId) revert InvalidCenterId();
        _;
    }

    modifier validCertificateId(uint256 _certificateId){
        uint256 certificateId = _certificateIdCounter.current();
        if(_certificateId > _certificateIdCounter.current()) revert CertificateNotExist();
        _;
    }
    modifier validPatientId(uint256 _patientId){
        uint256 patientId = _patientIdCounter.current();
        if(_patientId > patientId) revert InvalidPatientId();
        _;
    }

    modifier validCenterParams(address _center, string memory _centerName, string memory _leadBy, string memory _centerAddress, string memory _centerLocation){
        if(_center == address(0) || bytes(_centerName).length == 0 || bytes(_leadBy).length == 0 || bytes(_centerAddress).length == 0 || bytes(_centerLocation).length == 0) revert InvalidCenterParams();
        _;
    }

    modifier validPatientDetails(string memory _name, string memory _dateOfBirth, string memory _contactInformation, string memory _vaccineType, string memory _vaccinationDate){
        if(bytes(_name).length == 0 || bytes(_dateOfBirth).length == 0 || bytes(_contactInformation).length == 0 || bytes(_vaccineType).length == 0 || bytes(_vaccinationDate).length == 0) revert InvalidPatientDetails();
        _;
    }

    constructor() ERC721("VaccineCertification", "VAXCERT") Ownable(msg.sender) {}

    function addVaccinationCenter(address _center, string memory _centerName,string memory _leadBy, string memory _centerAddress, string memory _centerLocation) 
        external onlyOwner validCenterParams(_center , _centerName ,_leadBy , _centerAddress , _centerLocation)  
    {   
        if(centerAlreadyExist(_centerName)) revert CenterAlreadyExist();
        _centerIdCounter.increment();
        uint256 newCenterId = _centerIdCounter.current();
    
        centers[newCenterId] = Center(_center, _centerName, _leadBy,_centerAddress,_centerLocation);
        authorizedCenters[_center] = true;
    }

    function updateVaccinationCenter(uint256 _centerId, address _center, string memory _centerName, string memory _leadBy, string memory _centerAddress, string memory _centerLocation) 
       external onlyOwner validCenterId(_centerId) validCenterParams(_center , _centerName ,_leadBy , _centerAddress , _centerLocation) 
    {
        centers[_centerId] = Center(_center, _centerName, _leadBy, _centerAddress, _centerLocation);
        authorizedCenters[_center] = true;
    }

    function getCenterDetails(uint256 _centerId)
     external onlyOwner validCenterId(_centerId) view returns (Center memory)
    {
        return centers[_centerId];
    }

    function addPatientDetails(string memory _name, string memory _dateOfBirth, string memory _contactInformation, string memory _vaccineType, string memory _vaccinationDate)
      external onlyOwnerOrCenter validPatientDetails(_name,_dateOfBirth,_contactInformation,_vaccineType,_vaccinationDate)
    {   
        if(patientAlreadyExist(_dateOfBirth,_contactInformation)) revert PatientAlreadyExist();
        _patientIdCounter.increment();
        uint256 newPatientId = _patientIdCounter.current();
        patients[newPatientId] = Patient(_name, _dateOfBirth, _contactInformation, _vaccineType, _vaccinationDate);
    }

    function updatePatientDetails(uint256 _patientId, string memory _name, string memory _dateOfBirth, string memory _contactInformation, string memory _vaccineType, string memory _vaccinationDate)
    external onlyOwnerOrCenter validPatientId(_patientId) validPatientDetails(_name,_dateOfBirth,_contactInformation,_vaccineType,_vaccinationDate)
    {
        patients[_patientId] = Patient(_name, _dateOfBirth, _contactInformation, _vaccineType, _vaccinationDate);
    }

    function getPatientDetails(uint256 _patientId) external onlyOwnerOrCenter validPatientId(_patientId) view returns (Patient memory) {
        return patients[_patientId];
    }

    function generateCertificate(uint256 _patientId)
     external onlyOwnerOrCenter validPatientId(_patientId) returns (uint256)
    {   
        Patient memory patient = patients[_patientId];
        bytes32 hash = keccak256(abi.encodePacked(patient.name,patient.dateOfBirth, patient.contactInformation));
        address patientAddress = address(bytes20(hash)); 
        if(balanceOf(patientAddress) == 1) revert PatientAlreadyHasCertificate();

        _certificateIdCounter.increment();
        uint256 newCertificateId = _certificateIdCounter.current();
         
        _mint(patientAddress, newCertificateId);

        certificates[newCertificateId] = Certificate(false,msg.sender, patientAddress,_patientId);
        return newCertificateId;
    }

    function getCertificateDetails(uint256 _certificateId)
     external validCertificateId(_certificateId) view returns (Certificate memory)
    {   
        return certificates[_certificateId];
    }

    function isCertificateVerified(uint256 _certificateId)
     external validCertificateId(_certificateId) view returns(bool result) 
    {
       result = certificates[_certificateId].isVerified;
    }

    function verifyCertificate(uint256 _certificateId) 
    external onlyOwner validCertificateId(_certificateId)
    {
        bool isVerified = certificates[_certificateId].isVerified;  
        if(isVerified){
            revert AlreadyVerified();
        }  
        certificates[_certificateId].isVerified = true;
    }

    function tokenURI(uint256 tokenId)
     public pure override returns (string memory) 
    {
        return string(abi.encodePacked("https://djakjd/", Strings.toString(tokenId), ".json"));
    }

    function centerAlreadyExist(string memory _centerName) private view returns(bool){
        uint256 len = _centerIdCounter.current();
        for(uint256 i = 0; i <= len; i++){
            Center memory cen = centers[i];
            if(keccak256(bytes(_centerName)) == keccak256(bytes(cen.centerName))){
                return true;
            }
        }
        return false;
    }

    function patientAlreadyExist(string memory _dateOfBirth, string memory _contactInformation) private view returns(bool){
        uint256 len = _patientIdCounter.current();
        for(uint256 i = 0; i <= len; i++){
            Patient memory patient = patients[i];
            if(keccak256(bytes(_dateOfBirth)) == keccak256(bytes(patient.dateOfBirth)) && 
               keccak256(bytes(_contactInformation)) == keccak256(bytes(patient.contactInformation))){
                return true;
            }
        }
        return false;
    }
}