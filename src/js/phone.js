import phone from 'phone'

export const verifyPhone  = (phoneNum) => phone (phoneNum, {
    country: "",
    validateMobilePrefix: false,
    strictDetection: false
})
