// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MedicalRecords {
    /* -------------------- ROLES -------------------- */
    enum Role {
        NONE,
        PATIENT,
        DOCTOR
    }

    address public owner;
    uint256 private nextReportId = 1;

    /* -------------------- STRUCTS -------------------- */
    struct Report {
        uint256 id;
        address patient;
        address doctor;
        string cid;
        string meta;
        uint256 timestamp;
        bool exists;
    }

    struct DoctorProfile {
        string name;
        string qualification;
        string specialization;
        uint256 experience;
        bool exists;
    }

    /* -------------------- STORAGE -------------------- */
    mapping(address => Role) public roles;
    mapping(address => bool) public verifiedDoctors;
    mapping(address => DoctorProfile) public doctorProfiles;

    mapping(uint256 => Report) private reports;
    mapping(address => uint256[]) private patientReports;
    mapping(address => uint256[]) private doctorReports;

    address[] private verifiedDoctorList;
    address[] private allDoctors;

    /* -------------------- EVENTS -------------------- */
    event Registered(address user, Role role);
    event DoctorVerified(address doctor);
    event DoctorRevoked(address doctor);
    event DoctorProfileUpdated(address doctor);
    event ReportUploaded(uint256 reportId, address patient);
    event DoctorAssigned(uint256 reportId, address doctor);
    event ReportUpdated(uint256 reportId, address doctor);

    /* -------------------- MODIFIERS -------------------- */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyPatient() {
        require(roles[msg.sender] == Role.PATIENT, "Not a patient");
        _;
    }

    modifier onlyDoctor() {
        require(
            roles[msg.sender] == Role.DOCTOR && verifiedDoctors[msg.sender],
            "Doctor not verified"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /* -------------------- ROLE REGISTRATION -------------------- */
    function registerAsPatient() external {
        require(roles[msg.sender] == Role.NONE, "Already registered");
        roles[msg.sender] = Role.PATIENT;
        emit Registered(msg.sender, Role.PATIENT);
    }

    function registerAsDoctor() external {
        require(roles[msg.sender] == Role.NONE, "Already registered");
        roles[msg.sender] = Role.DOCTOR;

        allDoctors.push(msg.sender);
        emit Registered(msg.sender, Role.DOCTOR);
    }

    /* -------------------- DOCTOR PROFILE -------------------- */
    function setDoctorProfile(
        string calldata _name,
        string calldata _qualification,
        string calldata _specialization,
        uint256 _experience
    ) external {
        require(roles[msg.sender] == Role.DOCTOR, "Not a doctor");
        require(bytes(_name).length > 0, "Name required");

        doctorProfiles[msg.sender] = DoctorProfile({
            name: _name,
            qualification: _qualification,
            specialization: _specialization,
            experience: _experience,
            exists: true
        });

        emit DoctorProfileUpdated(msg.sender);
    }

    function getDoctorProfile(
        address _doctor
    )
        external
        view
        returns (
            string memory name,
            string memory qualification,
            string memory specialization,
            uint256 experience,
            bool verified
        )
    {
        require(doctorProfiles[_doctor].exists, "Profile not found");

        DoctorProfile storage p = doctorProfiles[_doctor];
        return (
            p.name,
            p.qualification,
            p.specialization,
            p.experience,
            verifiedDoctors[_doctor]
        );
    }

    /* -------------------- OWNER ACTIONS -------------------- */
    function verifyDoctor(address _doctor) external onlyOwner {
        require(roles[_doctor] == Role.DOCTOR, "Not registered doctor");
        require(!verifiedDoctors[_doctor], "Already verified");

        verifiedDoctors[_doctor] = true;
        verifiedDoctorList.push(_doctor);

        emit DoctorVerified(_doctor);
    }

    function revokeDoctor(address _doctor) external onlyOwner {
        verifiedDoctors[_doctor] = false;
        emit DoctorRevoked(_doctor);
    }

    function getAllDoctors()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return allDoctors;
    }

    function getVerifiedDoctors() external view returns (address[] memory) {
        return verifiedDoctorList;
    }

    /* -------------------- PATIENT ACTIONS -------------------- */
    function uploadReport(
        string calldata _cid,
        string calldata _meta
    ) external onlyPatient returns (uint256) {
        require(bytes(_cid).length > 0, "CID required");

        uint256 id = nextReportId++;

        reports[id] = Report({
            id: id,
            patient: msg.sender,
            doctor: address(0),
            cid: _cid,
            meta: _meta, //lets say this is description
            timestamp: block.timestamp,
            exists: true
        });

        patientReports[msg.sender].push(id);
        emit ReportUploaded(id, msg.sender);
        return id;
    }

    function assignDoctor(
        uint256 _reportId,
        address _doctor
    ) external onlyPatient {
        require(
            roles[_doctor] == Role.DOCTOR && verifiedDoctors[_doctor],
            "Doctor not verified"
        );

        Report storage r = reports[_reportId];
        require(r.exists, "Report not found");
        require(r.patient == msg.sender, "Not your report");

        r.doctor = _doctor;
        doctorReports[_doctor].push(_reportId);
        emit DoctorAssigned(_reportId, _doctor);
    }

    function getMyReports()
        external
        view
        onlyPatient
        returns (uint256[] memory)
    {
        return patientReports[msg.sender];
    }

    /* -------------------- DOCTOR ACTIONS -------------------- */
    function doctorUpdateReport(
        uint256 _reportId,
        string calldata _newCid,
        string calldata _newMeta
    ) external onlyDoctor {
        Report storage r = reports[_reportId];
        require(r.exists, "Report not found");
        require(r.doctor == msg.sender, "Not assigned to you");

        r.cid = _newCid;
        r.meta = _newMeta;
        r.timestamp = block.timestamp;

        emit ReportUpdated(_reportId, msg.sender);
    }

    function getAssignedReports()
        external
        view
        onlyDoctor
        returns (uint256[] memory)
    {
        return doctorReports[msg.sender];
    }

    /* -------------------- VIEW ACCESS -------------------- */
    function getReport(
        uint256 _reportId
    )
        external
        view
        returns (
            uint256 id,
            address patient,
            address doctor,
            string memory cid,
            string memory meta,
            uint256 timestamp
        )
    {
        Report storage r = reports[_reportId];
        require(r.exists, "Report not found");

        require(
            msg.sender == r.patient || msg.sender == r.doctor,
            "Not authorized"
        );

        return (r.id, r.patient, r.doctor, r.cid, r.meta, r.timestamp);
    }
}
