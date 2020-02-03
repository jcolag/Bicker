import React from "react";
import PropTypes from "prop-types";

class ReplyForm extends React.Component {
  render () {
    const id = `reply-form-${this.props.pnumber}-${this.props.count}`;
    return (
      <React.Fragment>
        <form
          id={id}
          className="reply-form"
        >
          <div>
            <textarea cols="80" rows="3" />
            <br />
            <button type="submit">Submit Reply</button>
          </div>
        </form>
      </React.Fragment>
    );
  }
}

ReplyForm.propTypes = {
  count: PropTypes.number,
  pnumber: PropTypes.number,
  text: PropTypes.string,
};
export default ReplyForm
