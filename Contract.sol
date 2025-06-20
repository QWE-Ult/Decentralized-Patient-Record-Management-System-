// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PatientRecords {
    // Define the structure of a patient record
    struct PatientRecord { 
        string name; 
        uint age;
        string diagnosis;
        string treatment;
        bool exists; // Flag to check if the record exists
    }
    // Mapping to store patient records by their address
    mapping(address => PatientRecord) private patientRecords;
    // Mapping to store authorized access for each patient 
    mapping(address => address[]) private authorizedAccess;
 
    address public owner;  
 
    // Declare events to log key actionS
    event RecordStored(address indexed patientAddress, string name);
    event AccessAuthorized(address indexed patientAddress, address indexed authorizedPerson);
    event AccessRevoked(address indexed patientAddress, address indexed revokedPerson);
    event RecordViewed(address indexed viewer, address indexed patientAddress);
    event RecordDeleted(address indexed patientAddress);  

    // Set the contract owner to the address that deploys the contract
    constructor() { 
        owner = msg.sender; // The contract deployer is the owner
    }

    // Modifier to ensure that only the patient or authorized person can access the record
    modifier onlyOwnerOrAuthorized(address patient) {
        require(msg.sender == patient || isAuthorized(patient), "Not authorized");
        _;
    }

    // Store a patient's record (only the owner can store records)
    function storeRecord(
        address patientAddress,
        string memory name,
        uint age,
        string memory diagnosis,
        string memory treatment
    ) public { 
        require(msg.sender == owner, "Only the owner can store records");

        // Store the patient's record
        patientRecords[patientAddress] = PatientRecord(name, age, diagnosis, treatment, true); 

        // Emit an event to log the record storage
        emit RecordStored(patientAddress, name);
    }

    // Authorize another person to access the patient's record
    function authorizeAccess(address patient, address authorizedPerson) public {
        require(msg.sender == patient, "Only the patient can authorize access");
        
        // Add the authorized person to the list of authorized addresses
        authorizedAccess[patient].push(authorizedPerson);

        // Emit an event to log the authorization
        emit AccessAuthorized(patient, authorizedPerson);
    }

    // Revoke access for an authorized person
    function revokeAccess(address patient, address authorizedPerson) public {
        require(msg.sender == patient, "Only the patient can revoke access");

        // Remove the authorized person from the list of authorized addresses
        address[] storage authorized = authorizedAccess[patient];
        for (uint i = 0; i < authorized.length; i++) {
            if (authorized[i] == authorizedPerson) {
                authorized[i] = authorized[authorized.length - 1];
                authorized.pop();
                break;
            }
        }

        // Emit an event to log the revocation
        emit AccessRevoked(patient, authorizedPerson);
    }

     // Check if an address is authorized to access a patient's record
     function isAuthorized(address patient) public view returns (bool) {
        address[] memory authorized = authorizedAccess[patient];
        for (uint i = 0; i < authorized.length; i++) {
            if (authorized[i] == msg.sender) {
                return true;
            }
        }
         return false;
    }

    // View a patient's record if authorized
    function viewRecord(address patientAddress) public  onlyOwnerOrAuthorized(patientAddress) returns (string memory name, uint age, string memory diagnosis, string memory treatment) {
        require(patientRecords[patientAddress].exists, "Record does not exist");

      // Retrieve the patient's record
        PatientRecord memory record = patientRecords[patientAddress];

        // Emit an event to log the record view 
        emit RecordViewed(msg.sender, patientAddress);

         // Return the patient's record details
        return (record.name, record.age, record.diagnosis, record.treatment);
    }
// Delete a patient's record (only the patient or owner can delete) 
    function deleteRecord(address patientAddress) public {
        require(msg.sender == patientAddress || msg.sender == owner, "Only the patient or owner can delete the record");
        require(patientRecords[patientAddress].exists, "Record does not exist");

        // Delete the record from the mapping
        delete patientRecords[patientAddress];

        // Emit an event to log the record deletion
        emit RecordDeleted(patientAddress);
    }
}
 
