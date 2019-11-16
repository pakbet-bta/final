pragma solidity ^0.5.0;

import "./ownable.sol";

contract PakbetUseCase is Ownable {
    event NewTemplate(address issuerAddress, string title, string description);
    event NewCertificate(bytes32 hashCode);
    event NewPremiumCertificate(bytes32 hashCode, address student);
    event NewIssuer(uint issuerId, string name);
    event NewStudent(uint256 id, address student);
    
    uint256 awardFee = 0.001 ether;
    
    struct Issuer {
        bool active;
        bool payPerAward;
        string name;
        uint256[] templatesCreated;
    }

    struct Template {
       address createdBy;
       string title;
       string description;
    }
    
    struct Certificate {
        uint256 issuedTo;
        uint256 issuedBy;
        uint256 templateUsed;
        uint32 date;
    }
    
    struct Student {
        address blockChainAccount;
        uint256[] certificatesOwned;
    }
    
    Certificate[] public certificates;
    Issuer[] public issuers;
    Student[] public students;
    Template[] public templates;

    mapping (address => bool) premiumStudents;
    mapping (address => bool) accreditedIssuers;
    mapping (address => uint256) addressToIssuer;
    mapping (address => uint256) addressToStudent;
    mapping (bytes32 => uint256) bytesToCertificate;
    mapping (bytes32 => bool) existingTemplates;
    mapping (bytes32 => bool) premiumCertificates;
    mapping (bytes32 => bool) regularCertificates;
    
    
    modifier isNotAccredited(address _issuerAddress) {
        require(!accreditedIssuers[_issuerAddress]);
        _;
    }
    
    modifier isAccredited(address _issuerAddress) {
        require(accreditedIssuers[_issuerAddress]);
        _;
    }
    
    modifier isNotExistingTemplate(bytes32 _hashCode) {
        require(!existingTemplates[_hashCode]);
        _;
    }
    
    modifier isExistingTemplate(bytes32 _hashCode) {
        require(existingTemplates[_hashCode]);
        _;
    }
    
    modifier canAward(address _issuer) {
        uint256 index = addressToIssuer[_issuer];
        
        require(accreditedIssuers[_issuer]);
        require (issuers[index].active);
        _;
    }
    
    /**
     * @return the number of accredited institution
     */ 
    function getIssuerCount() external view onlyOwner returns (uint256) {
        return issuers.length;
    }

    /**
     * @notice Add training institution to the blockchain.
     * @dev Only the owner of the smart contract account can call this function. 
     * @param _issuerAddress Blockchain Address associated to the training institution.
     * @param _name Name of the training institution.
     */
    function accreditIssuer(address _issuerAddress, string calldata _name) external onlyOwner {
        _accreditIssuer(_issuerAddress, _name);
    }
    
    /**
     * @notice Prevent a training institution from creating and awarding certificates.
     * @param _index uint256 value corresponding to the index position of the training institution
     * in the issuers[] array.
     */ 
    function deActivateIssuerById(uint256 _index) external onlyOwner {
        require(issuers[_index].active);
        issuers[_index].active = false;
    }

    /**
     * @notice Allows a training institution from creating and awarding certificates.
     * @param _index uint256 value corresponding to the index position of the training institution
     * in the issuers[] array.
     */ 
    function reActivateIssuerById(uint256 _index) external onlyOwner {
        require(!issuers[_index].active);
        issuers[_index].active = true;
    }
    
    /**
     * @notice Makes the training institution pay for every award.
     * @param _index uint256 value corresponding to the index position of the training institution
     * in the issuers[] array.
     */ 
    function setPaymentPerAward(uint256 _index) external onlyOwner {
        require(!issuers[_index].payPerAward);
        issuers[_index].payPerAward = true;
    }
    
    /**
     * @notice Makes the training institution not pay for every award.
     * @param _index uint256 value corresponding to the index position of the training institution
     * in the issuers[] array.
     */ 
    function setNoPaymentPerAward(uint256 _index) external onlyOwner {
        require(issuers[_index].payPerAward);
        issuers[_index].payPerAward = false;
    }
        
    /**
     * @notice Creates blank certificates which will become basis for certificates
     * to be issued.
     * @dev Only account in the issuer[] array can call this function.
     * @param _title certificate description e.g. Certificate of Attendance.
     * @param _description certificate description e.g. BTA Expert Program
     */
    function createTemplate(string calldata _title, string calldata _description) external isAccredited(msg.sender) {
        uint256 index = addressToIssuer[msg.sender];
        bytes32 hashCode = keccak256(abi.encode(_title, _description, issuers[index].name));
        _createTemplate(msg.sender, _title, _description, hashCode);
    }
    
    /**
     * @dev Record the hash value of the pdf document to the blockchain account.
     * @notice Only accredited account can call this function.
     * @return true if awarding of certificate is good, false if awarding of certificate fails.
     * @param _hashCode the resulting value when pdf is hashed.
     */
    function awardRegularCertificate(bytes32 _hashCode) external canAward(msg.sender) returns(bool) {
        uint256 index = addressToIssuer[msg.sender];
          
        require (issuers[index].payPerAward == false);
        require(!regularCertificates[_hashCode]);
        regularCertificates[_hashCode] = true;
        emit NewCertificate(_hashCode);
        return true;
    }
    
    /**
     * @param _templateId uint256 value corresponding to the index position of template in the templates[] array.
     * @param _hashCode the resulting value when pdf is hashed.
     * @param _studentAddress Blockchain Address associated to the student.
     */ 

    function awardPublicCertificates(
        uint256 _templateId, 
        bytes32 _hashCode, 
        address _studentAddress
    ) 
        external isAccredited(msg.sender) 
    {
        
        uint256 index = addressToIssuer[msg.sender];
        
        require (issuers[index].payPerAward == false);

        require(_templateId < templates.length);
        require(templates[_templateId].createdBy == msg.sender);
        require(premiumStudents[_studentAddress]);
        require(!premiumCertificates[_hashCode]);
        
        uint256 studentIndex = addressToStudent[_studentAddress];
        uint256 issuerIndex = addressToIssuer[msg.sender];
        
        uint256 id = certificates.push(Certificate(studentIndex, issuerIndex, _templateId, uint32(now))) - 1;
        premiumCertificates[_hashCode] = true;
        bytesToCertificate[_hashCode] = id;
        
        students[studentIndex].certificatesOwned.push(id);
    }
    
    /**
     * @dev Payable version of awardPublicCertificates
     * @param _templateId uint256 value corresponding to the index position of template in the templates[] array.
     * @param _hashCode the resulting value when pdf is hashed.
     * @param _studentAddress Blockchain Address associated to the student.
     */ 

    function awardPublicCertificatesPayable(
        uint256 _templateId, 
        bytes32 _hashCode, 
        address _studentAddress
    ) 
        external isAccredited(msg.sender) payable 
    {
        
        uint256 index = addressToIssuer[msg.sender];
        
        require (issuers[index].payPerAward == true);
        require(msg.value == awardFee);
        require(_templateId < templates.length);
        require(templates[_templateId].createdBy == msg.sender);
        require(premiumStudents[_studentAddress]);
        require(!premiumCertificates[_hashCode]);
        
        uint256 studentIndex = addressToStudent[_studentAddress];
        uint256 issuerIndex = addressToIssuer[msg.sender];
        
        uint256 id = certificates.push(Certificate(studentIndex, issuerIndex, _templateId, uint32(now))) - 1;
        premiumCertificates[_hashCode] = true;
        bytesToCertificate[_hashCode] = id;
        
        students[studentIndex].certificatesOwned.push(id);
    }

    /**
     * @dev Payable version of awardRegularCertificate.
     * @notice Only accredited account can call this function.
     * @return true if awarding of certificate is good, false if awarding of certificate fails.
     * @param _hashCode the resulting value when pdf is hashed.
     */
    function awardRegularCertificatePayable(bytes32 _hashCode) external canAward(msg.sender) payable returns(bool) {
        uint256 index = addressToIssuer[msg.sender];
        
        require (issuers[index].payPerAward == true);
        require(msg.value == awardFee);
        require(!regularCertificates[_hashCode]);
        regularCertificates[_hashCode] = true;
        emit NewCertificate(_hashCode);
        return true;
    }

    /**
     * @notice Add student to the blockchain.
     * @dev Only accredited account can call this function. 
     * @param _studentAddress Blockchain Address associated to the student.
     */ 
    function enrollStudent(address _studentAddress) external isAccredited(msg.sender) {
        require(!premiumStudents[_studentAddress]);
        _enrollStudent(_studentAddress);
    }
    /**
     * @dev transfer the ethers to owner's wallet
     */ 
    function withdraw() external onlyOwner {
        address payable _owner = ownerPayable();
        _owner.transfer(address(this).balance);
    }
    
    /**
     * @dev allows the owner to adjust fee
     */ 
    function setAwardFee(uint _fee) external onlyOwner {
        awardFee = _fee;
    }
    
    /**
     * @param _id uint256 value corresponding to the index position of the training institution
     * @return an array containing the template ids created template by the institution 
     */
    function getIssuedTemplates(uint256 _id) external view onlyOwner returns(uint256[] memory)  {
        require(_id < issuers.length);
        uint256[] memory result = new uint256[](issuers[_id].templatesCreated.length);
        
        for (uint i = 0; i < issuers[_id].templatesCreated.length; i++) {
            result[i] = issuers[_id].templatesCreated[i];
        }
        return result;
    }
  
    /**
     * @param _id uint256 value corresponding to the index position of the student
     * in the students[] array.
     * @return an array containing the certificate ids owned by the student.
     */ 
    function getStudentCertificates(uint256 _id) external view returns(uint256[] memory) {
        require (students[_id].blockChainAccount == msg.sender);
        uint256[] memory result = new uint256[](students[_id].certificatesOwned.length);
        
        for (uint i = 0; i < students[_id].certificatesOwned.length; i++) {
            result[i] = students[_id].certificatesOwned[i];
        }
        return result;
    }
    
    /**
     * @return true if Certificate exist in the blockchain, false if not.
     * @param _hashCode the resulting value when pdf is hashed.
     */
    function validateRegularCertificate(bytes32 _hashCode) external view returns(bool) {
        return (regularCertificates[_hashCode] || premiumCertificates[_hashCode]);
    }

    function _createTemplate(
        address _creator, 
        string memory _title, 
        string memory _description, 
        bytes32 _hashCode
    )
        internal isNotExistingTemplate(_hashCode) 
    {
        uint256 id = templates.length++;
        uint256 index = addressToIssuer[_creator];
        
        require (issuers[index].active);
        
        templates[id].createdBy = _creator;
        templates[id].title = _title;
        templates[id].description = _description;
        
        issuers[index].templatesCreated.push(id);
        existingTemplates[_hashCode] = true;
        emit NewTemplate(_creator, _title, _description);
    }

    function _accreditIssuer(address _issuerAddress, string memory _name) internal isNotAccredited(_issuerAddress) {
        uint256 id = issuers.length++;
        
        issuers[id].active = true;
        issuers[id].payPerAward = true;
        issuers[id].name = _name;
        
        accreditedIssuers[_issuerAddress] = true;
        addressToIssuer[_issuerAddress] = id;
        emit NewIssuer(id, _name);
    }

    function _enrollStudent(address _studentAccount) internal {
        uint256 id = students.length++;
        
        students[id].blockChainAccount = _studentAccount;
        premiumStudents[_studentAccount] = true;
        addressToStudent[_studentAccount] = id;
        emit NewStudent(id, _studentAccount);
   }
}
