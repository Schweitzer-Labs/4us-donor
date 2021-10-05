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
    organizationName: 'PDT Co'
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

    // cy.visit(appUrl)
    // cy.visit(`${appUrl}/demo`)

   // cy.get('#password').type(demoPassword)
   //  cy.get('.btn').click()
   //  cy.wait(12000)
   //  cy.get('.col-12 > a').then((e)=>{
   //      cy.visit(`${e.text()}/link-builder`)
   //  })
   //  cy.get('.d-block').then((e)=>{
   //      cy.visit(e.text())
   //  })



})

