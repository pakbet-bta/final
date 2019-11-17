

      var contract;


$(document).ready(function(){
  console.log('web3 current provider:', web3.currentProvider);
  // web3 = new Web3(web3.currentProvider);
  console.log('It is Working!')
  web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));

  // web3 = new Web3('http://127.0.0.1:7545');
  console.log(web3.version);
  console.log("current provider is " + web3.currentProvider.name);

  console.log('here', web3.eth.getAccounts(function(err, res) {if(!err) console.log(res)}))
  // web3.eth.getAccounts().then(console.log);
        
  var address = "0x31212C1C76E0aa567dEd44403507f7A392274110";
  var abi = [
      {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "students",
      "outputs": [
        {
          "name": "blockChainAccount",
          "type": "address"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [],
      "name": "ownerPayable",
      "outputs": [
        {
          "name": "",
          "type": "address"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "issuers",
      "outputs": [
        {
          "name": "active",
          "type": "bool"
        },
        {
          "name": "payPerAward",
          "type": "bool"
        },
        {
          "name": "name",
          "type": "string"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "certificates",
      "outputs": [
        {
          "name": "issuedTo",
          "type": "uint256"
        },
        {
          "name": "issuedBy",
          "type": "uint256"
        },
        {
          "name": "templateUsed",
          "type": "uint256"
        },
        {
          "name": "date",
          "type": "uint32"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "name": "",
          "type": "address"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [],
      "name": "isOwner",
      "outputs": [
        {
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "templates",
      "outputs": [
        {
          "name": "createdBy",
          "type": "address"
        },
        {
          "name": "title",
          "type": "string"
        },
        {
          "name": "description",
          "type": "string"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "name": "issuerAddress",
          "type": "address"
        },
        {
          "indexed": false,
          "name": "title",
          "type": "string"
        },
        {
          "indexed": false,
          "name": "description",
          "type": "string"
        }
      ],
      "name": "NewTemplate",
      "type": "event"
      },
      {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "name": "hashCode",
          "type": "bytes32"
        }
      ],
      "name": "NewCertificate",
      "type": "event"
      },
      {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "name": "hashCode",
          "type": "bytes32"
        },
        {
          "indexed": false,
          "name": "student",
          "type": "address"
        }
      ],
      "name": "NewPremiumCertificate",
      "type": "event"
      },
      {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "name": "issuerId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "name": "name",
          "type": "string"
        }
      ],
      "name": "NewIssuer",
      "type": "event"
      },
      {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "name": "id",
          "type": "uint256"
        },
        {
          "indexed": false,
          "name": "student",
          "type": "address"
        }
      ],
      "name": "NewStudent",
      "type": "event"
      },
      {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
      },
      {
      "constant": true,
      "inputs": [],
      "name": "getIssuerCount",
      "outputs": [
        {
          "name": "",
          "type": "uint256"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_issuerAddress",
          "type": "address"
        },
        {
          "name": "_name",
          "type": "string"
        }
      ],
      "name": "accreditIssuer",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_index",
          "type": "uint256"
        }
      ],
      "name": "deActivateIssuerById",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_index",
          "type": "uint256"
        }
      ],
      "name": "reActivateIssuerById",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_index",
          "type": "uint256"
        }
      ],
      "name": "setPaymentPerAward",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_index",
          "type": "uint256"
        }
      ],
      "name": "setNoPaymentPerAward",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_title",
          "type": "string"
        },
        {
          "name": "_description",
          "type": "string"
        }
      ],
      "name": "createTemplate",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_hashCode",
          "type": "bytes32"
        }
      ],
      "name": "awardRegularCertificate",
      "outputs": [
        {
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_templateId",
          "type": "uint256"
        },
        {
          "name": "_hashCode",
          "type": "bytes32"
        },
        {
          "name": "_studentAddress",
          "type": "address"
        }
      ],
      "name": "awardPublicCertificates",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_templateId",
          "type": "uint256"
        },
        {
          "name": "_hashCode",
          "type": "bytes32"
        },
        {
          "name": "_studentAddress",
          "type": "address"
        }
      ],
      "name": "awardPublicCertificatesPayable",
      "outputs": [],
      "payable": true,
      "stateMutability": "payable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_hashCode",
          "type": "bytes32"
        }
      ],
      "name": "awardRegularCertificatePayable",
      "outputs": [
        {
          "name": "",
          "type": "bool"
        }
      ],
      "payable": true,
      "stateMutability": "payable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_studentAddress",
          "type": "address"
        }
      ],
      "name": "enrollStudent",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [],
      "name": "withdraw",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": false,
      "inputs": [
        {
          "name": "_fee",
          "type": "uint256"
        }
      ],
      "name": "setAwardFee",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [
        {
          "name": "_id",
          "type": "uint256"
        }
      ],
      "name": "getIssuedTemplates",
      "outputs": [
        {
          "name": "",
          "type": "uint256[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [
        {
          "name": "_id",
          "type": "uint256"
        }
      ],
      "name": "getStudentCertificates",
      "outputs": [
        {
          "name": "",
          "type": "uint256[]"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      },
      {
      "constant": true,
      "inputs": [
        {
          "name": "_hashCode",
          "type": "bytes32"
        }
      ],
      "name": "validateRegularCertificate",
      "outputs": [
        {
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
      }
];

// console.log(abi)
contract = web3.eth.contract(abi);
contractInstance = contract.at(address)
// console.log(contractInstance)
}

)

