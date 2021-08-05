import phone from 'phone'

export const verifyPhone  = (phoneNum) =>
    phone (phoneNum, {country: "USA"}, true)
