import ExampleToken from "../contracts/ExampleToken.cdc"

// This transaction configures an account to store and receive tokens defined by the ExampleToken contract
transaction(signerAddress: Address){
    prepare(account: AuthAccount) {
        // Create a new empty Vault object
        let vaultA <- ExampleToken.createEmptyVault()

        // Store the vault in the account storage
        account.save<@ExampleToken.Vault>(<- vaultA, to: ExampleToken.VaultStoragePath)

        log("Empty Vault stored")

        // Create a public Receiver capability to the Vault
        let ReceiverRef = account.link<&ExampleToken.Vault{ExampleToken.Provider, ExampleToken.Receiver, ExampleToken.Balance}>
            (/public/VaultStoragePath, target: ExampleToken.VaultStoragePath)

        log("References created!")
    }

    post {
        // Check that the capabilities were created correctly
        getAccount(signerAddress).getCapability<&ExampleToken.Vault{ExampleToken.Receiver, ExampleToken.Provider, ExampleToken.Balance}>
            (/public/VaultStoragePath).check(): "Vault Receiver Reference was not created correctly!"
    }

    execute{

    }
}