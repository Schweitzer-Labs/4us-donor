const individual = {
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
    cy.get('[data-cy=contribIndEmail]').type(individual.email)
    cy.get('[data-cy=contribIndPhoneNumber]').type(individual.phoneNumber)
    cy.get('[data-cy=contribIndFirstName]').type(individual.firstName)
    cy.get('[data-cy=contribIndLastName]').type(individual.lastName)
    cy.get('[data-cy=contribIndAddress1]').type(individual.addressLine1)
    cy.get('[data-cy=contribIndAddress2]').type(individual.addressLine2)
    cy.get('[data-cy=contribIndCity]').type(individual.city)
    cy.get('[data-cy=contribIndState]').select(individual.state)
    cy.get('[data-cy=contribIndPostalCode]').type(individual.postalCode)
    cy.get('[data-cy=contribIndFAM]').click()
    cy.get('[data-cy=contribAffirm]').click()
    cy.get('[data-cy=continueBtn]').click()
    cy.get('[data-cy=contribCCNumber]').type(individual.creditCardNum)
    cy.get('[data-cy=contribCCM]').type(individual.creditCardMonth)
    cy.get('[data-cy=contribCCY]').type(individual.creditCardYear)
    cy.get('[data-cy=contribCCV]').type(individual.ccv)
})
