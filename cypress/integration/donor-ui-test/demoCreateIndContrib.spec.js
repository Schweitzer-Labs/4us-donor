describe("demo individual contributions",()=>{
    before(()=>{
        cy.generateDemo()
    })
    beforeEach(()=>{
        cy.initIndContrib()
    })

    it("can create a contribution",()=>{
        cy.fillIndForm()
        cy.get('[data-cy=donateBtn]').click()
    })
})
