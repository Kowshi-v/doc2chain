// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MedicalRecords {
    address public owner;
    uint256 private nextReportId;

    struct Report {
        uint256 id;
        address patient;
        address doctor;
        string cid;
        string meta;
        uint256 timestamp;
        bool exists;
    }

    mapping(uint256 => Report) private reports;
    mapping(address => uint256[]) private patientReports;
    mapping(address => bool) public isDoctor;

    event DoctorAdded(address doctor);
    event DoctorRemoved(address doctor);
    event ReportUploaded(uint256 reportId, address patient);
    event DoctorAssigned(uint256 reportId, address doctor);
    event ReportUpdated(uint256 reportId, address doctor);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyDoctor() {
        require(isDoctor[msg.sender], "Not an approved doctor");
        _;
    }

    constructor() {
        owner = msg.sender;
        nextReportId = 1;
    }

    function addDoctor(address _doctor) external onlyOwner {
        require(_doctor != address(0), "invalid address");
        require(!isDoctor[_doctor], "already doctor");
        isDoctor[_doctor] = true;
        emit DoctorAdded(_doctor);
    }

    function removeDoctor(address _doctor) external onlyOwner {
        require(isDoctor[_doctor], "not a doctor");
        isDoctor[_doctor] = false;
        emit DoctorRemoved(_doctor);
    }

    function uploadReport(
        string calldata _cid,
        string calldata _meta
    ) external returns (uint256) {
        require(bytes(_cid).length > 0, "CID required");

        uint256 id = nextReportId++;

        reports[id] = Report({
            id: id,
            patient: msg.sender,
            doctor: address(0),
            cid: _cid,
            meta: _meta,
            timestamp: block.timestamp,
            exists: true
        });

        patientReports[msg.sender].push(id);

        emit ReportUploaded(id, msg.sender);
        return id;
    }

    function assignDoctor(uint256 _reportId, address _doctor) external {
        require(isDoctor[_doctor], "Not a verified doctor");
        Report storage r = reports[_reportId];

        require(r.exists, "Report not found");
        require(r.patient == msg.sender, "Only patient can assign doctor");

        r.doctor = _doctor;

        emit DoctorAssigned(_reportId, _doctor);
    }

    function doctorUpdateReport(
        uint256 _reportId,
        string calldata _newCid,
        string calldata _newMeta
    ) external onlyDoctor {
        Report storage r = reports[_reportId];

        require(r.exists, "Report not found");
        require(r.doctor == msg.sender, "Not assigned to this report");

        r.cid = _newCid;
        r.meta = _newMeta;
        r.timestamp = block.timestamp;

        emit ReportUpdated(_reportId, msg.sender);
    }

    function getReport(uint256 _reportId) external view returns (
        uint256 id,
        address patient,
        address doctor,
        string memory cid,
        string memory meta,
        uint256 timestamp
    ) {
        Report storage r = reports[_reportId];
        require(r.exists, "Report not found");

        require(
            msg.sender == r.patient || 
            msg.sender == r.doctor || 
            msg.sender == owner,
            "Not authorized"
        );

        return (r.id, r.patient, r.doctor, r.cid, r.meta, r.timestamp);
    }

    function getMyReports() external view returns (uint256[] memory) {
        return patientReports[msg.sender];
    }
}
