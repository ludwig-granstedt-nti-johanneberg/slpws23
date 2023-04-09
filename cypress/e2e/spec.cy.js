describe('Create, manage and delete account', () => {
  it('Creates an account', () => {
    cy.visit("127.0.0.1:4567")
    cy.get('#sign-up-link').click()

    cy.url().should('include', '/signup')

    cy.get('#username-input').type('testuser')
    cy.get('#email-input').type('test@example.com')
    cy.get('#email-confirm-input').type('test@example.com')
    cy.get('#password-input').type('testpassword')
    cy.get('#password-confirm-input').type('testpassword')

    cy.get('#signup-submit').click();

    cy.get('#error-message').should('not.exist')
  });

  it('Changes email and username', () => {
    cy.visit('127.0.0.1:4567')
    cy.get('#sign-in-link').click()

    cy.url().should('include', '/signin')

    cy.get('#username-input').type('testuser')
    cy.get('#password-input').type('testpassword')

    cy.get('#submit-button').click();

    cy.url().should('include', '/')

    cy.get('#user-nav-button').click()
    cy.get('#settings-link').click()

    cy.url().should('include', '/settings/account')

    cy.get('#username').clear().type('testuser2')
    cy.get('#email').clear().type('test2@example.com')

    cy.get('#update-information-submit').click()

    cy.get('#error-modal').should('not.exist')
  });

  it('Changes password', () => {
    cy.visit('127.0.0.1:4567')
    cy.get('#sign-in-link').click()

    cy.url().should('include', '/signin')

    cy.get('#username-input').type('testuser2')
    cy.get('#password-input').type('testpassword')

    cy.get('#submit-button').click();

    cy.url().should('include', '/')

    cy.get('#user-nav-button').click()
    cy.get('#settings-link').click()

    cy.url().should('include', '/settings/account')

    cy.get('#password').type('testpassword2')
    cy.get('#password-confirm').type('testpassword2')
    cy.get('#current-password').type('testpassword')

    cy.get('#update-password-submit').click()

    cy.get('#error-modal').should('not.exist')

  });

  it('Deletes account', () => {
    cy.visit('127.0.0.1:4567')
    cy.get('#sign-in-link').click()

    cy.url().should('include', '/signin')

    cy.get('#username-input').type('testuser2')
    cy.get('#password-input').type('testpassword2')

    cy.get('#submit-button').click();

    cy.url().should('include', '/')

    cy.get('#user-nav-button').click()
    cy.get('#settings-link').click()

    cy.url().should('include', '/settings/account')

    cy.get('#delete-account-button').click()

    cy.get('#confirm-delete-button').click()

    cy.get('#delete-account-password-confirm').type('testpassword2')

    cy.get('#confirm-delete-button2').click()

    cy.get('#error-modal').should('not.exist')
  });
});