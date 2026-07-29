package sh.cliq.backend.user.validator

import jakarta.validation.ConstraintValidator
import jakarta.validation.ConstraintValidatorContext
import sh.cliq.backend.error.ErrorCode
import sh.cliq.backend.user.UserRepository

class EmailOccupiedValidator(private val userRepository: UserRepository) :
    ConstraintValidator<EmailOccupiedConstraint, String> {

    override fun isValid(value: String?, context: ConstraintValidatorContext): Boolean {
        if (value.isNullOrEmpty()) {
            return true
        }

        val occupied = userRepository.existsByEmail(value)

        if (occupied) {
            context.disableDefaultConstraintViolation()
            context
                .buildConstraintViolationWithTemplate(ErrorCode.EMAIL_ALREADY_OCCUPIED.code.toString())
                .addConstraintViolation()
        }

        return !occupied
    }
}
