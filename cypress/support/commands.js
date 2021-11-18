const donor = {
    firstName : 'William',
    lastName: 'Faulkner',
    amount: '10',
    paymentDate: '2021-09-17',
    email: '4us@gmail.com',
    phoneNumber: '2369860981',
    addressLine1 :'1234 Broadway',
    addressLine2: 'Apartment 5',
    city : 'Manhattan',
    state: 'New York',
    postalCode: '10356',
    company: 'Toyota',
    job: 'Marketing',
    purposeCode: 'LITER',
    organizationName: 'PDT Co',
    creditCardNum: '4242424242424242',
    creditCardMonth: '04',
    creditCardYear: '2024',
    ccv: '123'
}
const mutation = `
    mutation(
        $password: String!
        $demoType: DemoType
    ) {
        generateCommittee(
            genCommittee: {
            password: $password,
                demoType: $demoType
        }
    ) {
            id
        }
    }
`

const appUrl = 'http://localhost:3001/committee/'
const password = 'f4jp1i'
const demoType = 'Clean'

Cypress.Commands.add('generateDemo', () => {
    cy.request({
        url: 'http://localhost:4000/',
        method: 'POST',
        body: {query: mutation, variables:{password, demoType}},
        failOnStatusCode: false
    }).then((res) => {
    const id = res.body.data.generateCommittee.id
        cy.visit(`${appUrl}${id}`)
});

})

Cypress.Commands.add('initIndContrib', ()=>{
    cy.get('.form-control').type('10')
    cy.get('.col > .btn').click()
    cy.get('#Individual').click()
})

Cypress.Commands.add('fillIndForm',()=>{
    cy.get('[data-cy=contribIndEmail]').type(donor.email)
    cy.get('[data-cy=contribIndPhoneNumber]').type(donor.phoneNumber)
    cy.get('[data-cy=contribIndFirstName]').type(donor.firstName)
    cy.get('[data-cy=contribIndLastName]').type(donor.lastName)
    cy.get('[data-cy=contribIndAddress1]').type(donor.addressLine1)
    cy.get('[data-cy=contribIndAddress2]').type(donor.addressLine2)
    cy.get('[data-cy=contribIndCity]').type(donor.city)
    cy.get('[data-cy=contribIndState]').select(donor.state)
    cy.get('[data-cy=contribIndPostalCode]').type(donor.postalCode)
    cy.get('[data-cy=contribIndFAM]').click()
    cy.get('[data-cy=contribAffirm]').click()
    cy.get('[data-cy=continueBtn]').click()
    cy.get('[data-cy=contribCCNumber]').type(donor.creditCardNum)
    cy.get('[data-cy=contribCCM]').type(donor.creditCardMonth)
    cy.get('[data-cy=contribCCY]').type(donor.creditCardYear)
    cy.get('[data-cy=contribCCV]').type(donor.ccv)
})
