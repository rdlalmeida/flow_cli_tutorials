/*
    This transaction is used to create new accounts (on the offline emulator for now). As such, the transaction requires a public key
    (as a String) to be provided to add to the account to create.
*/
transaction(publicKey: String) {
    /*
        IMPORTANT: The signer of this transaction is the account that is going to pay for the instructions needed to create the new account. Therefore,
        account creation needs to come from the "outside", i.e., from an account with enough funds to do that. As a suggestion, using the service account
        is an easy way to deal with this
    */
    prepare(signer: AuthAccount) {
        let pub_key = PublicKey(
            /*
                The publicKey is provided to the transaction as a String but this instruction requires an array of UInt8 ([UInt8]). It is much
                more easy to get the key as String, therefore it is necessary to convert it to the [UInt8] required. The decodeHex() instruction
                does just that
            */
            publicKey: publicKey.decodeHex(),

            // This one is pretty much standard in Flow/Cadence
            signatureAlgorithm: SignatureAlgorithm.ECDSA_P256
        )

        /*
            Create a bare account. Notice how the AuthAccount object is used to create this new "object" (I think...) but it requires a signer
            with enough funds to pay for the gas costs as argument.
        */
        let newAccount = AuthAccount(payer: signer)

        // This is a bit redundant and it serves just to ensure that I get the address of the account created somewhere (it should be set in
        // transaction's output too)
        log("New Account created with address ".concat(newAccount.address.toString()))

        // Add public key to account created. Notice that it is the Publickey object and not the String that goes here
        newAccount.keys.add(
            publicKey: pub_key,
            // The hash algorithm is also pretty much standard
            hashAlgorithm: HashAlgorithm.SHA3_256,
            // IMPORTANT: Recent rule changes in Flow/Cadence now require accounts with a minimum weight of 1000 to be able to sign... things.
            // So, yeah, make sure this value is at least 1000.0
            weight: 1000.0
        )

        log("Created account with address ".concat(newAccount.address.toString()).concat("with Public Key = ").concat(publicKey[0].toString()))
    }

    execute {
        
    }
}