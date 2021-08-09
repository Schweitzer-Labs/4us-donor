import * as EmailValidator from "email-validator"

export const verifyEmail = (email) => EmailValidator.validate(email)
