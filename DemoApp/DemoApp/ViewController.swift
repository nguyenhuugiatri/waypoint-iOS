import UIKit

// Import Waypoint SDK
import waypoint
let WAYPOINT_ORIGIN = "https://id.skymavis.one"
let CLIENT_ID = "47a4e1a9-2483-4233-9197-364ee5bd2935"
// Testnet
let CHAIN_ID = 2021
let RPC_URL = "https://saigon-testnet.roninchain.com/rpc"

class ViewController: UIViewController {
    let waypoint = Waypoint(
        waypointOrigin: WAYPOINT_ORIGIN,
        clientId: CLIENT_ID,
        chainRpc: RPC_URL,
        chainId: CHAIN_ID
    )
    
    let redirect = "mydapp2://open"

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "ronin")
        return imageView
    }()

    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)

        // Button styling
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 10

        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground // Set the view's background color

        let buttonTitles = ["Authorize", "Guests", "Register", "Send Native Token", "Personal Sign", "Sign Type Data", "Swap RON"]
        let buttonSelectors: [Selector] = [#selector(authorizeTapped), #selector(authWithGuests), #selector(registerGuests), #selector(sendNativeTokenTapped), #selector(personalSignTapped), #selector(signTypeDataTapped), #selector(callContractTapped)]

        // Create a vertical stack view to hold the buttons
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10 // Space between buttons
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Add buttons to the stack view
        for (index, title) in buttonTitles.enumerated() {
            let button = createButton(title: title)
            button.addTarget(self, action: buttonSelectors[index], for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        // Add the stack view to the main view
        self.view.addSubview(stackView)

        // Set constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5) // Responsive width
        ])

        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    public func handleDeepLink(result: String) {

        let response = Utils.parseDeepLink(deeplink: result)
        let message = """
                   Address: \(String(describing: response.getAddress()))
                   Success: \(String(describing: response.getSuccess()))
                   Data: \(String(describing: response.getData()))
                   Method: \(String(describing: response.getMethod()))
                   State: \(String(describing: response.getState()))
                   """
        // Create and configure the alert controller
        let alertController = UIAlertController(title: "Deep Link Info", message: message, preferredStyle: .alert)

        // Add an OK action to dismiss the alert
        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        // Present the alert
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }

    }
    let testSenderAddress = "0x8DBdA66e04B5Ee0277db9c025a7cb96Ed57E1218"

    @objc func authorizeTapped() {
        // Implement the action for the Authorize
        let state = Utils.generateRandomState()
        var scopes: [String] = ["email", "propile", "openid", "wallet"]
        Task {
            let result = await waypoint.authorize(from: self, state: state, redirect: redirect)
            print("Auth result : \(result)")
            self.handleDeepLink(result: result)
        }
    }

    @objc func sendNativeTokenTapped() {
        // Implement the action for the Send Transaction button
        let state = Utils.generateRandomState()
        let to = "0xD36deD8E1927dCDD76Bfe0CC95a5C1D65c0a807a"
        let value = "100000000000000000"
        Task {
            let result = await waypoint.sendNativeToken(from: self, state: state, redirect: redirect, to: to, value: value)
            self.handleDeepLink(result: result)
        }
    }

    @objc func personalSignTapped() {
        let state = Utils.generateRandomState()
        // Implement the action for the Personal Sign button
        Task {
            let result = await waypoint.personalSign(from: self, state: state, redirect: redirect, message: "Hello Axie")
            self.handleDeepLink(result: result)
        }
    }

    @objc func signTypeDataTapped() {
        // Implement the action for the Sign Type Data button
        let typedData = """
       {
           "types": {
               "Asset": [
                   {"name": "erc", "type": "uint8"},
                   {"name": "addr", "type": "address"},
                   {"name": "id", "type": "uint256"},
                   {"name": "quantity", "type": "uint256"}
               ],
               "Order": [
                   {"name": "maker", "type": "address"},
                   {"name": "kind", "type": "uint8"},
                   {"name": "assets", "type": "Asset[]"},
                   {"name": "expiredAt", "type": "uint256"},
                   {"name": "paymentToken", "type": "address"},
                   {"name": "startedAt", "type": "uint256"},
                   {"name": "basePrice", "type": "uint256"},
                   {"name": "endedAt", "type": "uint256"},
                   {"name": "endedPrice", "type": "uint256"},
                   {"name": "expectedState", "type": "uint256"},
                   {"name": "nonce", "type": "uint256"},
                   {"name": "marketFeePercentage", "type": "uint256"}
               ],
               "EIP712Domain": [
                   {"name": "name", "type": "string"},
                   {"name": "version", "type": "string"},
                   {"name": "chainId", "type": "uint256"},
                   {"name": "verifyingContract", "type": "address"}
               ]
           },
           "domain": {
               "name": "MarketGateway",
               "version": "1",
               "chainId": 2021,
               "verifyingContract": "0xfff9ce5f71ca6178d3beecedb61e7eff1602950e"
           },
           "primaryType": "Order",
           "message": {
               "maker": "0xd761024b4ef3336becd6e802884d0b986c29b35a",
               "kind": "1",
               "assets": [
                   {
                       "erc": "1",
                       "addr": "0x32950db2a7164ae833121501c797d79e7b79d74c",
                       "id": "2730069",
                       "quantity": "0"
                   }
               ],
               "expiredAt": "1721709637",
               "paymentToken": "0xc99a6a985ed2cac1ef41640596c5a5f9f4e19ef5",
               "startedAt": "1705984837",
               "basePrice": "500000000000000000",
               "endedAt": "0",
               "endedPrice": "0",
               "expectedState": "0",
               "nonce": "0",
               "marketFeePercentage": "425"
           }
       }
       """
        let state = Utils.generateRandomState()
        Task {
            let result = await waypoint.signTypedData(from: self, state: state, redirect: redirect, typedData: typedData)
            self.handleDeepLink(result: result)
        }
    }
    // Swap RON to AXS
    @objc func callContractTapped() {
        // Implement the action for the Call Contract button
        let katanaAddress = "0xda44546c0715ae78d454fe8b84f0235081584fe0"
        let data = "0x7da5cd6600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000e872c1237e559bc961cc34670cb56ecf5aef7281000000000000000000000000000000000000000000000000000000006729c85d0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000a959726154953bae111746e265e6d754f48570e60000000000000000000000003c4e17b9056272ce1b49f6900d8cfd6171a1869d"
        let value = "100000000000000000"
        let state = Utils.generateRandomState()
        Task {
            let result = await waypoint.sendTransaction(from: self, state: state, redirect: redirect, to: katanaAddress, data: data, value: value)
            self.handleDeepLink(result: result)
        }
    }

    @objc func authWithGuests() {
        let credential = "credentialk9"
        let authDate = "1727174140"
        let hash = "83b411e928d89cb4820101ecdf2f29944c0496fc2f92d2a2aa1f09193261af8a"
        let state = Utils.generateRandomState()
        Task {
            let result = await waypoint.authAsGuest(from: self, state: state, redirect: redirect, credential: credential, authDate: authDate, hash: hash, scope: "wallet")
            self.handleDeepLink(result: result)
        }
    }

    @objc func registerGuests() {
        let state = Utils.generateRandomState()
        Task {
            let result = await waypoint.registerGuestAccount(from: self, state: state, redirect: redirect)
            self.handleDeepLink(result: result)
        }
    }
}
