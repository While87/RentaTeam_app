/*************************************************************************
 *
 * Copyright 2021 Realm Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **************************************************************************/

#pragma once

#include <atomic>
#include <cstdint>
#include <iosfwd>
#include <string>

#include "realm/error_codes.hpp"
#include "realm/string_data.hpp"
#include "realm/util/bind_ptr.hpp"
#include "realm/util/features.h"

namespace realm {

class [[nodiscard]] Status {
public:
    /*
     * This is the best way to construct a Status that represents a non-error condition.
     */
    static inline Status OK();

    /*
     * You can construct a Status from strings, C strings, and StringData's.
     */
    Status(ErrorCodes::Error code, StringData reason);
    Status(ErrorCodes::Error code, const std::string& reason);
    Status(ErrorCodes::Error code, const char* reason);

    /*
     * Copying a Status is just copying an intrusive pointer - i.e. very cheap. Moving them is similarly cheap.
     */
    inline Status(const Status& other);
    inline Status& operator=(const Status& other);

    inline Status(Status&& other) noexcept;
    inline Status& operator=(Status&& other) noexcept;

    inline bool is_ok() const noexcept;
    inline const std::string& reason() const noexcept;
    inline ErrorCodes::Error code() const noexcept;
    inline StringData code_string() const noexcept;

    /*
     * This class is marked nodiscard so that we always handle errors. If there is a place where we need
     * to explicitly ignore an error, you can call this function, which does nothing, to satisfy the compiler.
     */
    void ignore() const noexcept {}

private:
    Status() = default;

    struct ErrorInfo {
        mutable std::atomic<uint32_t> m_refs;
        const ErrorCodes::Error m_code;
        const std::string m_reason;

        static util::bind_ptr<ErrorInfo> create(ErrorCodes::Error code, StringData reason);

    protected:
        template <typename>
        friend class ::realm::util::bind_ptr;

        inline void bind_ptr() const noexcept
        {
            m_refs.fetch_add(1, std::memory_order_relaxed);
        }

        inline void unbind_ptr() const noexcept
        {
            if (m_refs.fetch_sub(1, std::memory_order_acq_rel) == 1) {
                delete this;
            }
        }

    private:
        ErrorInfo(ErrorCodes::Error code, StringData reason);
    };

    util::bind_ptr<ErrorInfo> m_error = {};
};

class ExceptionForStatus : public std::exception {
public:
    const char* what() const noexcept final
    {
        return reason().c_str();
    }

    const Status& to_status() const
    {
        return m_status;
    }

    const std::string& reason() const noexcept
    {
        return m_status.reason();
    }

    ErrorCodes::Error code() const noexcept
    {
        return m_status.code();
    }

    StringData code_string() const noexcept
    {
        return m_status.code_string();
    }

    ExceptionForStatus(ErrorCodes::Error err, StringData str)
        : m_status(err, str)
    {
    }

    explicit ExceptionForStatus(Status status)
        : m_status(std::move(status))
    {
    }

private:
    Status m_status;
};

/*
 * This will convert an exception in a catch(...) block into a Status. For ExceptionForStatus's, it returns the
 * status held in the exception directly. Otherwise it returns a status with an UnknownError error code and a
 * reason string holding the exception type and message.
 *
 * Currently this works for exceptions that derive from std::exception or ExceptionForStatus only.
 */
Status exception_to_status() noexcept;

std::ostream& operator<<(std::ostream& out, const Status& val);

inline bool operator==(const Status& lhs, const Status& rhs) noexcept
{
    return lhs.code() == rhs.code();
}

inline bool operator!=(const Status& lhs, const Status& rhs) noexcept
{
    return lhs.code() != rhs.code();
}

inline bool operator==(const Status& lhs, ErrorCodes::Error rhs) noexcept
{
    return lhs.code() == rhs;
}

inline bool operator!=(const Status& lhs, ErrorCodes::Error rhs) noexcept
{
    return lhs.code() != rhs;
}

inline Status Status::OK()
{
    // Returns a status with m_error set to nullptr.
    return Status{};
}

inline Status::Status(const Status& other)
    : m_error(other.m_error)
{
}

inline Status& Status::operator=(const Status& other)
{
    m_error = other.m_error;
    return *this;
}

inline Status::Status(Status&& other) noexcept
    : m_error(std::move(other.m_error))
{
}

inline Status& Status::operator=(Status&& other) noexcept
{
    m_error = std::move(other.m_error);
    return *this;
}

inline bool Status::is_ok() const noexcept
{
    return !m_error;
}

inline const std::string& Status::reason() const noexcept
{
    static const std::string empty;
    return m_error ? m_error->m_reason : empty;
}

inline ErrorCodes::Error Status::code() const noexcept
{
    return m_error ? m_error->m_code : ErrorCodes::OK;
}

inline StringData Status::code_string() const noexcept
{
    return ErrorCodes::error_string(code());
}

} // namespace realm
